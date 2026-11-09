import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'android_printer_transport.dart';
import 'printer_adapter.dart';
import 'printer_config_store.dart';
import 'printer_models.dart';
import 'printer_permissions.dart';
import 'printer_transport.dart';

enum PrinterConnectionStatus {
  unconfigured,
  disconnected,
  connecting,
  connected,
}

class PrinterState {
  const PrinterState({
    this.config,
    this.status = PrinterConnectionStatus.unconfigured,
    this.busy = false,
    this.failureKind,
    this.message,
    this.permissionsGranted = false,
    this.permissionChecked = false,
    this.discovered = const [],
    this.lastTestPrintAt,
  });

  final PrinterConfig? config;
  final PrinterConnectionStatus status;
  final bool busy;
  final PrinterFailureKind? failureKind;

  /// Actionable guidance or latest success note shown under the status.
  final String? message;
  final bool permissionsGranted;
  final bool permissionChecked;
  final List<PrinterConnection> discovered;
  final DateTime? lastTestPrintAt;

  bool get isConfigured => config != null;

  bool get transportSupported => config?.transport.implemented ?? false;

  bool get canTestPrint => status == PrinterConnectionStatus.connected;

  String get statusLabel {
    return switch (status) {
      PrinterConnectionStatus.unconfigured => 'Not configured',
      PrinterConnectionStatus.disconnected => 'Disconnected',
      PrinterConnectionStatus.connecting => 'Connecting',
      PrinterConnectionStatus.connected => 'Connected',
    };
  }

  PrinterState copyWith({
    PrinterConfig? config,
    PrinterConnectionStatus? status,
    bool? busy,
    PrinterFailureKind? failureKind,
    String? message,
    bool? permissionsGranted,
    bool? permissionChecked,
    List<PrinterConnection>? discovered,
    DateTime? lastTestPrintAt,
    bool clearFailure = false,
    bool clearMessage = false,
    bool clearConfig = false,
    bool clearLastTest = false,
  }) {
    return PrinterState(
      config: clearConfig ? null : (config ?? this.config),
      status: status ?? this.status,
      busy: busy ?? this.busy,
      failureKind: clearFailure ? null : (failureKind ?? this.failureKind),
      message: clearMessage ? null : (message ?? this.message),
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      permissionChecked: permissionChecked ?? this.permissionChecked,
      discovered: discovered ?? this.discovered,
      lastTestPrintAt: clearLastTest
          ? null
          : (lastTestPrintAt ?? this.lastTestPrintAt),
    );
  }
}

final printerPermissionServiceProvider = Provider<PrinterPermissionService>(
  (ref) => const AndroidPrinterPermissionService(),
);

final printerTransportProvider = Provider<PrinterTransport>(
  (ref) => AndroidBluetoothPrinterTransport(),
);

final printerConfigStoreProvider = Provider<PrinterConfigStore>(
  (ref) => SecurePrinterConfigStore(ref.watch(secureStorageProvider)),
);

final printerAdapterProvider = Provider<PrinterAdapter>(
  (ref) => EscPosPrinterAdapter(transport: ref.watch(printerTransportProvider)),
);

final printerControllerProvider =
    AsyncNotifierProvider<PrinterController, PrinterState>(
      PrinterController.new,
    );

class PrinterController extends AsyncNotifier<PrinterState> {
  late PrinterConfigStore _store;
  late PrinterAdapter _adapter;
  late PrinterPermissionService _permissions;

  @override
  Future<PrinterState> build() async {
    _store = ref.watch(printerConfigStoreProvider);
    _adapter = ref.watch(printerAdapterProvider);
    _permissions = ref.watch(printerPermissionServiceProvider);

    final config = await _store.load();
    final permission = await _permissions.check();
    return PrinterState(
      config: config,
      status: config == null
          ? PrinterConnectionStatus.unconfigured
          : PrinterConnectionStatus.disconnected,
      permissionsGranted: permission == PrinterPermissionStatus.granted,
      permissionChecked: true,
    );
  }

  PrinterState get _current => state.value ?? const PrinterState();

  void _publish(PrinterState next) {
    state = AsyncData(next);
  }

  Future<void> saveConfig(PrinterConfig config) async {
    if (_adapter.isConnected) {
      await _adapter.disconnect();
    }
    await _store.save(config);
    final permission = config.transport.implemented
        ? await _permissions.check()
        : PrinterPermissionStatus.unsupportedPlatform;
    _publish(
      _current.copyWith(
        config: config,
        status: PrinterConnectionStatus.disconnected,
        busy: false,
        permissionsGranted: permission == PrinterPermissionStatus.granted,
        permissionChecked: true,
        discovered: const [],
        clearFailure: true,
        clearLastTest: true,
        message: config.transport.implemented
            ? 'Printer saved. Connect to run a test print.'
            : '${config.transport.label} is not verified on this project. '
                  'Only Bluetooth Classic is implemented in this build.',
      ),
    );
  }

  Future<void> requestPermissions() async {
    _publish(_current.copyWith(busy: true, clearFailure: true));
    final permission = await _permissions.request();
    if (permission == PrinterPermissionStatus.granted) {
      _publish(
        _current.copyWith(
          busy: false,
          permissionsGranted: true,
          permissionChecked: true,
          message: 'Bluetooth permission granted.',
        ),
      );
      return;
    }
    if (permission == PrinterPermissionStatus.unsupportedPlatform) {
      _fail(
        PrinterFailureKind.unknown,
        'Runtime permissions are unavailable on this platform. '
        'Bluetooth printer testing requires an Android device.',
      );
      return;
    }
    _fail(
      PrinterFailureKind.permissionDenied,
      'Bluetooth permission was denied. Tap Grant Bluetooth permission to '
      'ask again, or enable it in Android app settings.',
    );
  }

  Future<void> discover() async {
    final config = _current.config;
    if (config == null) {
      _fail(
        PrinterFailureKind.notConnected,
        'Save a printer configuration before discovering devices.',
      );
      return;
    }
    if (!config.transport.implemented) {
      _failTransport();
      return;
    }
    if (!await _permissionsGranted()) {
      _failPermission();
      return;
    }
    _publish(
      _current.copyWith(
        busy: true,
        clearFailure: true,
        clearMessage: true,
        discovered: const [],
      ),
    );
    try {
      final connections = await _adapterTransportDiscover();
      _publish(
        _current.copyWith(
          busy: false,
          discovered: connections,
          message: connections.isEmpty
              ? 'No paired devices found. Pair the printer in Android '
                    'Bluetooth settings, then refresh.'
              : 'Found ${connections.length} paired device'
                    '${connections.length == 1 ? '' : 's'}.',
        ),
      );
    } catch (error) {
      _failFrom(error);
    }
  }

  Future<void> connect() async {
    final config = _current.config;
    if (config == null) {
      _fail(
        PrinterFailureKind.notConnected,
        'Save a printer configuration before connecting.',
      );
      return;
    }
    if (!config.transport.implemented) {
      _failTransport();
      return;
    }
    if (!await _permissionsGranted()) {
      _failPermission();
      return;
    }

    _publish(
      _current.copyWith(
        status: PrinterConnectionStatus.connecting,
        busy: true,
        clearFailure: true,
        clearMessage: true,
      ),
    );
    try {
      await _adapter.connect(config);
      _publish(
        _current.copyWith(
          status: PrinterConnectionStatus.connected,
          busy: false,
          message:
              'Connected to ${config.connection.name}. Run a test print '
              'to confirm the paper output.',
        ),
      );
    } catch (error) {
      _failFrom(error);
    }
  }

  Future<void> testPrint() async {
    final config = _current.config;
    if (config == null) {
      _fail(
        PrinterFailureKind.notConnected,
        'Save and connect a printer before running a test print.',
      );
      return;
    }
    if (!config.transport.implemented) {
      _failTransport();
      return;
    }
    if (_current.status != PrinterConnectionStatus.connected ||
        !_adapter.isConnected) {
      _fail(
        PrinterFailureKind.notConnected,
        'Connect to the printer before sending a test print.',
      );
      return;
    }

    _publish(
      _current.copyWith(busy: true, clearFailure: true, clearMessage: true),
    );
    try {
      await _adapter.testPrint();
      _publish(
        _current.copyWith(
          busy: false,
          lastTestPrintAt: DateTime.now(),
          message:
              'Test print bytes sent. Confirm the paper output on the '
              'printer. Physical delivery is not verified until a real model '
              'is tested.',
        ),
      );
    } catch (error) {
      _failFrom(error);
    }
  }

  Future<void> disconnect() async {
    await _adapter.disconnect();
    _publish(
      _current.copyWith(
        status: PrinterConnectionStatus.disconnected,
        busy: false,
        clearFailure: true,
        message: 'Disconnected.',
      ),
    );
  }

  Future<void> clearConfig() async {
    if (_adapter.isConnected) {
      await _adapter.disconnect();
    }
    await _store.clear();
    _publish(
      _current.copyWith(
        clearConfig: true,
        status: PrinterConnectionStatus.unconfigured,
        busy: false,
        discovered: const [],
        clearFailure: true,
        clearLastTest: true,
        clearMessage: true,
      ),
    );
  }

  Future<List<PrinterConnection>> _adapterTransportDiscover() {
    final transport = ref.read(printerTransportProvider);
    return transport.discover();
  }

  Future<bool> _permissionsGranted() async {
    final permission = await _permissions.check();
    final granted = permission == PrinterPermissionStatus.granted;
    if (granted != _current.permissionsGranted) {
      _publish(
        _current.copyWith(permissionsGranted: granted, permissionChecked: true),
      );
    }
    return granted;
  }

  void _failPermission() {
    _fail(
      PrinterFailureKind.permissionDenied,
      'Bluetooth permission is required. Tap Grant Bluetooth permission and '
      'retry.',
    );
  }

  void _failTransport() {
    _fail(
      PrinterFailureKind.unsupportedTransport,
      '${_current.config?.transport.label ?? 'This transport'} is not '
      'verified on this project. Only Bluetooth Classic is implemented in '
      'this build.',
    );
  }

  void _fail(PrinterFailureKind kind, String message) {
    _publish(
      _current.copyWith(
        busy: false,
        status: kind == PrinterFailureKind.notConnected
            ? PrinterConnectionStatus.disconnected
            : _current.status,
        failureKind: kind,
        message: message,
      ),
    );
  }

  void _failFrom(Object error) {
    if (error is PrinterException) {
      final disconnected =
          error.kind == PrinterFailureKind.connectionLost ||
          error.kind == PrinterFailureKind.deviceNotFound ||
          error.kind == PrinterFailureKind.notConnected;
      _publish(
        _current.copyWith(
          busy: false,
          status: disconnected
              ? PrinterConnectionStatus.disconnected
              : _current.status,
          failureKind: error.kind,
          message: error.userMessage,
        ),
      );
      return;
    }
    _fail(
      PrinterFailureKind.unknown,
      'The printer operation failed. Check the connection and retry.',
    );
  }
}
