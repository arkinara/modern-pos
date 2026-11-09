package com.modernpos.modern_pos_mobile

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Hosts the Bluetooth Classic (RFCOMM/SPP) socket behind the
 * `modern_pos/printer` method channel. Dart owns receipt rendering and order of
 * operations; this class only checks Android permissions and moves bytes.
 *
 * Physical printer behaviour is PENDING until tested with a real model and
 * Android device. See docs/printer-validation.md.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "modern_pos/printer"
        private const val PERMISSION_REQUEST_CODE = 4801

        // Standard Bluetooth Serial Port Profile (SPP) service UUID.
        private val SPP_UUID: UUID =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    }

    private var socket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkPermissions" -> result.success(permissionState())
                    "requestPermissions" -> handlePermissionRequest(result)
                    "listPairedDevices" -> listPairedDevices(result)
                    "connect" -> {
                        val address = call.argument<String>("address")
                        if (address == null) {
                            result.error("invalid_argument", "Missing device address", null)
                        } else {
                            connectDevice(address, result)
                        }
                    }
                    "write" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("invalid_argument", "Missing byte payload", null)
                        } else {
                            writeBytes(bytes, result)
                        }
                    }
                    "disconnect" -> {
                        closeSocket()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun permissionsGranted(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
                PackageManager.PERMISSION_GRANTED &&
                checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) ==
                PackageManager.PERMISSION_GRANTED
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED
        }
        return true
    }

    private fun permissionState(): Map<String, Any> {
        val needsRuntimePermission = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
        return mapOf(
            "granted" to permissionsGranted(),
            "canRequest" to needsRuntimePermission,
            "sdkInt" to Build.VERSION.SDK_INT,
        )
    }

    private fun requiredRuntimePermissions(): Array<String> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return arrayOf(
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_SCAN,
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        return emptyArray()
    }

    private fun handlePermissionRequest(result: MethodChannel.Result) {
        val required = requiredRuntimePermissions()
        if (required.isEmpty() || permissionsGranted()) {
            result.success(permissionState())
            return
        }
        if (pendingPermissionResult != null) {
            result.error("permission_pending", "A permission request is already in progress", null)
            return
        }
        pendingPermissionResult = result
        requestPermissions(required, PERMISSION_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != PERMISSION_REQUEST_CODE) {
            return
        }
        val result = pendingPermissionResult
        pendingPermissionResult = null
        result?.success(permissionState())
    }

    @SuppressLint("MissingPermission")
    private fun listPairedDevices(result: MethodChannel.Result) {
        if (!permissionsGranted()) {
            result.error("permission_denied", "Bluetooth permissions are not granted", null)
            return
        }
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null) {
            result.error("bluetooth_unsupported", "This device has no Bluetooth adapter", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("bluetooth_disabled", "Bluetooth is turned off", null)
            return
        }
        try {
            val devices = adapter.bondedDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unnamed device"),
                    "address" to device.address,
                )
            }
            result.success(devices)
        } catch (error: SecurityException) {
            result.error("permission_denied", error.message, null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectDevice(address: String, result: MethodChannel.Result) {
        if (!permissionsGranted()) {
            result.error("permission_denied", "Bluetooth permissions are not granted", null)
            return
        }
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter == null) {
            result.error("bluetooth_unsupported", "This device has no Bluetooth adapter", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("bluetooth_disabled", "Bluetooth is turned off", null)
            return
        }
        val device = try {
            adapter.getRemoteDevice(address)
        } catch (error: IllegalArgumentException) {
            result.error("device_not_found", "Invalid or unknown printer address", null)
            return
        }

        executor.execute {
            try {
                closeSocket()
                val nextSocket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                adapter.cancelDiscovery()
                nextSocket.connect()
                socket = nextSocket
                outputStream = nextSocket.outputStream
                mainHandler.post { result.success(true) }
            } catch (error: SecurityException) {
                closeSocket()
                mainHandler.post {
                    result.error("permission_denied", error.message, null)
                }
            } catch (error: Exception) {
                closeSocket()
                mainHandler.post {
                    result.error("connection_failed", error.message ?: "Connection failed", null)
                }
            }
        }
    }

    private fun writeBytes(bytes: ByteArray, result: MethodChannel.Result) {
        val stream = outputStream
        if (stream == null) {
            result.error("not_connected", "No printer connection is open", null)
            return
        }
        executor.execute {
            try {
                stream.write(bytes)
                stream.flush()
                mainHandler.post { result.success(true) }
            } catch (error: Exception) {
                closeSocket()
                mainHandler.post {
                    result.error("connection_lost", error.message ?: "Write failed", null)
                }
            }
        }
    }

    private fun closeSocket() {
        try {
            outputStream?.close()
        } catch (_: Exception) {
            // Best-effort teardown.
        }
        try {
            socket?.close()
        } catch (_: Exception) {
            // Best-effort teardown.
        }
        outputStream = null
        socket = null
    }

    override fun onDestroy() {
        closeSocket()
        executor.shutdownNow()
        super.onDestroy()
    }
}
