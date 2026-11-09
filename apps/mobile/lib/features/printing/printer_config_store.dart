import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'printer_models.dart';

/// Persists the cashier's printer selection on the device.
abstract interface class PrinterConfigStore {
  Future<PrinterConfig?> load();

  Future<void> save(PrinterConfig config);

  Future<void> clear();
}

class SecurePrinterConfigStore implements PrinterConfigStore {
  SecurePrinterConfigStore(this._storage);

  static const _key = 'printer_config_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<PrinterConfig?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return PrinterConfig.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      // Corrupt or older config is treated as never configured.
      return null;
    }
  }

  @override
  Future<void> save(PrinterConfig config) async {
    await _storage.write(key: _key, value: jsonEncode(config.toJson()));
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
