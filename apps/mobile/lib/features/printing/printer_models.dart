/// Printer domain models shared by the cashier UI and the receipt adapter.
///
/// Hardware support is intentionally conservative: only the Bluetooth Classic
/// (RFCOMM/SPP) candidate has a transport implementation. No model, paper
/// width, code page or command is claimed as verified until a real printer is
/// tested. See `docs/printer-validation.md`.
library;

/// Transports the operator can select. Every transport has an adapter in this
/// build; physical delivery is still pending for each real hardware model.
enum PrinterTransportType {
  bluetoothClassic('bluetooth_classic', 'Bluetooth Classic (SPP)'),
  network('network', 'Network (LAN)'),
  usb('usb', 'USB');

  const PrinterTransportType(this.wireName, this.label);

  final String wireName;
  final String label;

  bool get implemented => true;

  /// Only the Bluetooth Classic transport asks for Android Bluetooth
  /// permissions. LAN and USB do not use the Bluetooth radio.
  bool get requiresBluetooth => this == PrinterTransportType.bluetoothClassic;

  static PrinterTransportType fromWireName(String? value) {
    return PrinterTransportType.values.firstWhere(
      (type) => type.wireName == value,
      orElse: () => PrinterTransportType.bluetoothClassic,
    );
  }
}

/// Receipt paper width. Column counts are the common ESC/POS Font A convention
/// (32 columns for 58 mm, 48 for 80 mm); the exact count for a real model is
/// PENDING device verification.
enum PaperWidth {
  mm58(58, 32, '58 mm'),
  mm80(80, 48, '80 mm');

  const PaperWidth(this.millimetres, this.columns, this.label);

  final int millimetres;
  final int columns;
  final String label;

  static PaperWidth fromMillimetres(int? value) {
    return PaperWidth.values.firstWhere(
      (width) => width.millimetres == value,
      orElse: () => PaperWidth.mm58,
    );
  }
}

/// Text code page usable by the byte-stream builder. The real printer code page
/// must be confirmed with the model manual before this is trusted on hardware.
enum PrinterEncoding {
  cp437('cp437', 'CP437'),
  utf8('utf8', 'UTF-8');

  const PrinterEncoding(this.wireName, this.label);

  final String wireName;
  final String label;

  static PrinterEncoding fromWireName(String? value) {
    return PrinterEncoding.values.firstWhere(
      (encoding) => encoding.wireName == value,
      orElse: () => PrinterEncoding.cp437,
    );
  }
}

/// A candidate connection target. [address] is an Android Bluetooth MAC for the
/// Bluetooth Classic transport, `host:port` for LAN, and the Android USB device
/// id for USB.
class PrinterConnection {
  const PrinterConnection({
    required this.transport,
    required this.name,
    required this.address,
  });

  final PrinterTransportType transport;
  final String name;
  final String address;

  Map<String, Object?> toJson() => {
    'transport': transport.wireName,
    'name': name,
    'address': address,
  };

  static PrinterConnection? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final address = json['address'] as String?;
    if (address == null || address.isEmpty) {
      return null;
    }
    return PrinterConnection(
      transport: PrinterTransportType.fromWireName(
        json['transport'] as String?,
      ),
      name: json['name'] as String? ?? address,
      address: address,
    );
  }
}

/// Cashier-selected printer configuration persisted on the device.
class PrinterConfig {
  const PrinterConfig({
    required this.connection,
    required this.paperWidth,
    required this.encoding,
    this.serverId,
  });

  final PrinterConnection connection;
  final PaperWidth paperWidth;
  final PrinterEncoding encoding;

  /// Server printer-configuration id when the configuration was linked to the
  /// `printing_*` contract. Null means the local queue works but job metadata
  /// cannot be mirrored to the API.
  final String? serverId;

  PrinterTransportType get transport => connection.transport;

  PrinterConfig copyWith({
    PrinterConnection? connection,
    PaperWidth? paperWidth,
    PrinterEncoding? encoding,
    String? serverId,
  }) {
    return PrinterConfig(
      connection: connection ?? this.connection,
      paperWidth: paperWidth ?? this.paperWidth,
      encoding: encoding ?? this.encoding,
      serverId: serverId ?? this.serverId,
    );
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'connection': connection.toJson(),
    'paperWidthMm': paperWidth.millimetres,
    'encoding': encoding.wireName,
    if (serverId != null) 'serverId': serverId,
  };

  static PrinterConfig? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final connection = PrinterConnection.fromJson(
      (json['connection'] as Map?)?.cast<String, Object?>(),
    );
    if (connection == null) {
      return null;
    }
    return PrinterConfig(
      connection: connection,
      paperWidth: PaperWidth.fromMillimetres(json['paperWidthMm'] as int?),
      encoding: PrinterEncoding.fromWireName(json['encoding'] as String?),
      serverId: json['serverId'] as String?,
    );
  }
}

/// Classified failures the UI can turn into actionable, retryable messages.
enum PrinterFailureKind {
  permissionDenied,
  bluetoothDisabled,
  bluetoothUnsupported,
  deviceNotFound,
  connectionLost,
  printRejected,
  unsupportedTransport,
  notConnected,
  unknown,
}

class PrinterException implements Exception {
  const PrinterException(this.kind, this.message, {this.platformCode});

  final PrinterFailureKind kind;
  final String message;
  final String? platformCode;

  /// Human-readable, actionable guidance shown in the cashier UI.
  String get userMessage {
    return switch (kind) {
      PrinterFailureKind.permissionDenied =>
        'Bluetooth permission is required. Grant the permission and retry.',
      PrinterFailureKind.bluetoothDisabled =>
        'Bluetooth is off. Turn it on in Android settings and retry.',
      PrinterFailureKind.bluetoothUnsupported =>
        'This device does not report Bluetooth support. Use a device with '
            'Bluetooth to connect the printer.',
      PrinterFailureKind.deviceNotFound =>
        'Printer not found. Power it on, pair it in Android Bluetooth '
            'settings, then retry.',
      PrinterFailureKind.connectionLost =>
        'The printer connection dropped. Reconnect and run the test print '
            'again.',
      PrinterFailureKind.printRejected =>
        'The printer rejected the job. Check paper, cover and power, then '
            'retry.',
      PrinterFailureKind.unsupportedTransport =>
        'This transport is not available in this build. Choose an available '
            'transport and retry.',
      PrinterFailureKind.notConnected =>
        'Connect to the printer before sending a test print.',
      PrinterFailureKind.unknown =>
        'The printer operation failed. Check the connection and retry.',
    };
  }

  static PrinterFailureKind kindFromPlatformCode(String? code) {
    return switch (code) {
      'permission_denied' => PrinterFailureKind.permissionDenied,
      'bluetooth_disabled' => PrinterFailureKind.bluetoothDisabled,
      'bluetooth_unsupported' => PrinterFailureKind.bluetoothUnsupported,
      'device_not_found' => PrinterFailureKind.deviceNotFound,
      'connection_lost' => PrinterFailureKind.connectionLost,
      'connection_failed' => PrinterFailureKind.connectionLost,
      'print_rejected' => PrinterFailureKind.printRejected,
      'not_connected' => PrinterFailureKind.notConnected,
      _ => PrinterFailureKind.unknown,
    };
  }

  @override
  String toString() => 'PrinterException($kind, $message)';
}
