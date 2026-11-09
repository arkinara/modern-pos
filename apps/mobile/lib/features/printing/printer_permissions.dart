import 'package:flutter/services.dart';

/// Android runtime-permission state for the Bluetooth Classic transport.
enum PrinterPermissionStatus { granted, denied, unsupportedPlatform }

abstract interface class PrinterPermissionService {
  Future<PrinterPermissionStatus> check();

  Future<PrinterPermissionStatus> request();
}

/// Calls the Android host to check/request Bluetooth permissions.
///
/// Permission rules come from the Android platform docs: API 31+ needs
/// `BLUETOOTH_CONNECT`/`BLUETOOTH_SCAN` at runtime, while API 23-30 needs
/// `ACCESS_FINE_LOCATION` for discovery with install-time `BLUETOOTH`/
/// `BLUETOOTH_ADMIN`. On-device behaviour is `PENDING — requires Android
/// device`.
class AndroidPrinterPermissionService implements PrinterPermissionService {
  const AndroidPrinterPermissionService();

  static const MethodChannel channel = MethodChannel('modern_pos/printer');

  @override
  Future<PrinterPermissionStatus> check() async {
    try {
      final result = await channel.invokeMapMethod<String, Object?>(
        'checkPermissions',
      );
      return _statusFrom(result);
    } on MissingPluginException {
      return PrinterPermissionStatus.unsupportedPlatform;
    } on PlatformException {
      return PrinterPermissionStatus.denied;
    }
  }

  @override
  Future<PrinterPermissionStatus> request() async {
    try {
      final result = await channel.invokeMapMethod<String, Object?>(
        'requestPermissions',
      );
      return _statusFrom(result);
    } on MissingPluginException {
      return PrinterPermissionStatus.unsupportedPlatform;
    } on PlatformException {
      return PrinterPermissionStatus.denied;
    }
  }

  PrinterPermissionStatus _statusFrom(Map<String, Object?>? result) {
    if (result?['granted'] == true) {
      return PrinterPermissionStatus.granted;
    }
    return PrinterPermissionStatus.denied;
  }
}
