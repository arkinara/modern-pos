package com.modernpos.modern_pos_mobile

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Android USB host transport behind `modern_pos/printer_usb`.
 *
 * The Dart transport owns receipt bytes and state. This host only discovers
 * devices, requests USB permission, claims a bulk OUT interface and writes the
 * byte payload. Physical output is PENDING until tested with a real printer.
 */
class UsbPrinterChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    companion object {
        private const val CHANNEL = "modern_pos/printer_usb"
        private const val ACTION_USB_PERMISSION = "com.modernpos.modern_pos_mobile.USB_PERMISSION"
        private const val TIMEOUT_MILLIS = 5000
    }

    private val manager: UsbManager? =
        activity.getSystemService(Context.USB_SERVICE) as? UsbManager
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private var connection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var outEndpoint: UsbEndpoint? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingDeviceId: Int? = null

    private val permissionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action != ACTION_USB_PERMISSION) {
                return
            }
            val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
            val result = pendingResult
            pendingResult = null
            if (device == null || result == null) {
                result?.error("device_not_found", "USB permission result had no device", null)
                return
            }
            if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                openDevice(device, result)
            } else {
                result.error("permission_denied", "USB permission was denied", null)
            }
        }
    }

    init {
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(permissionReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(permissionReceiver, filter)
        }

        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "listDevices" -> result.success(listDevices())
                "connect" -> {
                    val deviceId = call.argument<String>("deviceId")
                    if (deviceId == null) {
                        result.error("invalid_argument", "Missing USB device id", null)
                    } else {
                        connect(deviceId, result)
                    }
                }
                "write" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("invalid_argument", "Missing byte payload", null)
                    } else {
                        write(bytes, result)
                    }
                }
                "disconnect" -> {
                    close()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun listDevices(): List<Map<String, Any>> {
        val usbManager = manager ?: return emptyList()
        return usbManager.deviceList.values.map { device ->
            mapOf(
                "deviceId" to device.deviceId.toString(),
                "name" to (device.productName ?: device.manufacturerName ?: "USB printer"),
            )
        }
    }

    private fun connect(deviceId: String, result: MethodChannel.Result) {
        val usbManager = manager
        val numericId = deviceId.toIntOrNull()
        if (usbManager == null || numericId == null) {
            result.error("device_not_found", "USB device was not found", null)
            return
        }
        val device = usbManager.deviceList.values.firstOrNull { it.deviceId == numericId }
        if (device == null) {
            result.error("device_not_found", "USB device was not found", null)
            return
        }
        if (!usbManager.hasPermission(device)) {
            if (pendingResult != null) {
                result.error("permission_pending", "A USB permission request is already open", null)
                return
            }
            pendingResult = result
            pendingDeviceId = numericId
            val intent = PendingIntent.getBroadcast(
                activity,
                numericId,
                Intent(ACTION_USB_PERMISSION).setPackage(activity.packageName),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            usbManager.requestPermission(device, intent)
            return
        }
        openDevice(device, result)
    }

    private fun openDevice(device: UsbDevice, result: MethodChannel.Result) {
        val usbManager = manager
        if (usbManager == null) {
            result.error("device_not_found", "USB host is unavailable", null)
            return
        }
        close()
        var target: UsbInterface? = null
        for (index in 0 until device.interfaceCount) {
            val candidate = device.getInterface(index)
            if (findOutEndpoint(candidate) != null) {
                target = candidate
                break
            }
        }
        if (target == null) {
            result.error("print_rejected", "No USB bulk OUT endpoint was found", null)
            return
        }
        val endpoint = findOutEndpoint(target)
        val nextConnection = usbManager.openDevice(device)
        if (nextConnection == null) {
            result.error("connection_failed", "Could not open the USB device", null)
            return
        }
        if (!nextConnection.claimInterface(target, true)) {
            nextConnection.close()
            result.error("connection_failed", "Could not claim the USB interface", null)
            return
        }
        usbInterface = target
        outEndpoint = endpoint
        connection = nextConnection
        result.success(true)
    }

    private fun findOutEndpoint(candidate: UsbInterface): UsbEndpoint? {
        for (index in 0 until candidate.endpointCount) {
            val endpoint = candidate.getEndpoint(index)
            if (
                endpoint.type == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                endpoint.direction == UsbConstants.USB_DIR_OUT
            ) {
                return endpoint
            }
        }
        return null
    }

    private fun write(bytes: ByteArray, result: MethodChannel.Result) {
        val activeConnection = connection
        val endpoint = outEndpoint
        if (activeConnection == null || endpoint == null) {
            result.error("not_connected", "No USB printer connection is open", null)
            return
        }
        executor.execute {
            try {
                val sent = activeConnection.bulkTransfer(endpoint, bytes, bytes.size, TIMEOUT_MILLIS)
                if (sent < 0) {
                    close()
                    activity.runOnUiThread {
                        result.error("connection_lost", "USB bulk transfer failed", null)
                    }
                } else {
                    activity.runOnUiThread { result.success(true) }
                }
            } catch (error: Exception) {
                close()
                activity.runOnUiThread {
                    result.error("connection_lost", error.message ?: "USB write failed", null)
                }
            }
        }
    }

    private fun close() {
        try {
            connection?.releaseInterface(usbInterface)
        } catch (_: Exception) {
            // Best-effort teardown.
        }
        try {
            connection?.close()
        } catch (_: Exception) {
            // Best-effort teardown.
        }
        connection = null
        usbInterface = null
        outEndpoint = null
    }

    fun dispose() {
        close()
        executor.shutdownNow()
        try {
            activity.unregisterReceiver(permissionReceiver)
        } catch (_: Exception) {
            // Receiver was not registered or the activity is finishing.
        }
    }
}
