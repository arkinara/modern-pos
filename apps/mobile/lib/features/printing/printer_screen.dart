import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'printer_controller.dart';
import 'printer_models.dart';

/// Cashier-facing printer configuration and connection surface.
///
/// This screen can configure, connect and send a test byte stream. It never
/// reports physical print success without a real device; see
/// `docs/printer-validation.md`.
class PrinterScreen extends ConsumerStatefulWidget {
  const PrinterScreen({super.key});

  @override
  ConsumerState<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends ConsumerState<PrinterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _addressController = TextEditingController();

  PrinterTransportType _transport = PrinterTransportType.bluetoothClassic;
  PaperWidth _paperWidth = PaperWidth.mm58;
  PrinterEncoding _encoding = PrinterEncoding.cp437;
  bool _seeded = false;

  @override
  void dispose() {
    _deviceNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _seedFrom(PrinterConfig? config) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    if (config == null) {
      return;
    }
    _transport = config.transport;
    _paperWidth = config.paperWidth;
    _encoding = config.encoding;
    _deviceNameController.text = config.connection.name;
    _addressController.text = config.connection.address;
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt printer')),
      body: printer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PrinterLoadError(
          onRetry: () => ref.invalidate(printerControllerProvider),
        ),
        data: (state) {
          _seedFrom(state.config);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _CandidateNotice(),
              const SizedBox(height: 12),
              if (!state.isConfigured) ...[
                const _FirstRunCard(),
                const SizedBox(height: 12),
              ],
              _buildConfigForm(context, state),
              const SizedBox(height: 16),
              _StatusCard(state: state),
              const SizedBox(height: 16),
              _buildActions(context, state),
              if (state.isConfigured) ...[
                const SizedBox(height: 24),
                _buildDangerZone(context, state),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigForm(BuildContext context, PrinterState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.isConfigured ? 'Change configuration' : 'Configuration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PrinterTransportType>(
                initialValue: _transport,
                decoration: const InputDecoration(
                  labelText: 'Transport',
                  border: OutlineInputBorder(),
                ),
                items: PrinterTransportType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: state.busy
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _transport = value);
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Printer name (optional)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Connection address',
                  hintText: switch (_transport) {
                    PrinterTransportType.bluetoothClassic =>
                      'AA:BB:CC:DD:EE:FF',
                    PrinterTransportType.network => '192.168.1.50:9100',
                    PrinterTransportType.usb => 'USB device id',
                  },
                  helperText: switch (_transport) {
                    PrinterTransportType.bluetoothClassic =>
                      'Bluetooth Classic: pair the printer in Android settings '
                          'first.',
                    PrinterTransportType.network =>
                      'LAN: enter host:port. Raw TCP port 9100 is used when the '
                          'port is omitted.',
                    PrinterTransportType.usb =>
                      'USB: grant USB access when Android prompts, then enter the '
                          'device id or scan devices.',
                  },
                  border: const OutlineInputBorder(),
                ),
                autocorrect: false,
                textCapitalization: _transport == PrinterTransportType.network
                    ? TextCapitalization.none
                    : TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the printer address or identifier.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PaperWidth>(
                      initialValue: _paperWidth,
                      decoration: const InputDecoration(
                        labelText: 'Paper width',
                        border: OutlineInputBorder(),
                      ),
                      items: PaperWidth.values
                          .map(
                            (width) => DropdownMenuItem(
                              value: width,
                              child: Text(
                                '${width.label} (${width.columns} cols)',
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: state.busy
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _paperWidth = value);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<PrinterEncoding>(
                      initialValue: _encoding,
                      decoration: const InputDecoration(
                        labelText: 'Encoding',
                        border: OutlineInputBorder(),
                      ),
                      items: PrinterEncoding.values
                          .map(
                            (encoding) => DropdownMenuItem(
                              value: encoding,
                              child: Text(encoding.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: state.busy
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _encoding = value);
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: state.busy ? null : () => _save(state),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, PrinterState state) {
    final controller = ref.read(printerControllerProvider.notifier);
    final needsBluetooth = state.config?.transport.requiresBluetooth ?? true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Connection', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (!state.isConfigured)
              const Text(
                'Save a configuration first, then connect and run a test print.',
                style: TextStyle(color: PosColors.muted),
              )
            else ...[
              if (!needsBluetooth)
                const Text(
                  'This transport does not use Android Bluetooth permissions.',
                  style: TextStyle(color: PosColors.muted, fontSize: 13),
                ),
              if (needsBluetooth)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (state.permissionsGranted)
                      const _PermissionChip(granted: true)
                    else
                      FilledButton.tonalIcon(
                        onPressed: state.busy
                            ? null
                            : controller.requestPermissions,
                        icon: const Icon(Icons.lock_open_outlined),
                        label: const Text('Grant Bluetooth permission'),
                      ),
                    OutlinedButton.icon(
                      onPressed: state.busy ? null : controller.discover,
                      icon: const Icon(Icons.bluetooth_searching),
                      label: const Text('Scan paired devices'),
                    ),
                  ],
                ),
              if (needsBluetooth && !state.permissionsGranted) ...[
                const SizedBox(height: 8),
                const Text(
                  'Android asks for Bluetooth connect/scan permission. '
                  'If denied, use Grant Bluetooth permission to ask again.',
                  style: TextStyle(color: PosColors.muted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: state.busy || !state.canTestPrint
                        ? null
                        : controller.testPrint,
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Test print'),
                  ),
                  if (state.status == PrinterConnectionStatus.connected)
                    OutlinedButton.icon(
                      onPressed: state.busy ? null : controller.disconnect,
                      icon: const Icon(Icons.link_off),
                      label: const Text('Disconnect'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: state.busy ? null : controller.connect,
                      icon: const Icon(Icons.link),
                      label: const Text('Connect'),
                    ),
                ],
              ),
              if (state.canTestPrint && state.lastTestPrintAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last test sent ${_formatTime(state.lastTestPrintAt!)}. '
                  'Confirm the paper output.',
                  style: const TextStyle(color: PosColors.muted, fontSize: 13),
                ),
              ],
              if (state.discovered.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Paired devices',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                for (final device in state.discovered)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.print_outlined),
                    title: Text(device.name),
                    subtitle: Text(device.address),
                    trailing: const Text('Use'),
                    onTap: state.busy
                        ? null
                        : () {
                            setState(() {
                              _transport = device.transport;
                              _deviceNameController.text = device.name;
                              _addressController.text = device.address;
                            });
                          },
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, PrinterState state) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: state.busy ? null : () => _confirmClear(context, state),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Remove printer configuration'),
      ),
    );
  }

  void _save(PrinterState state) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final address = _addressController.text.trim();
    final name = _deviceNameController.text.trim();
    final config = PrinterConfig(
      connection: PrinterConnection(
        transport: _transport,
        name: name.isEmpty ? address : name,
        address: address,
      ),
      paperWidth: _paperWidth,
      encoding: _encoding,
    );
    ref.read(printerControllerProvider.notifier).saveConfig(config);
  }

  Future<void> _confirmClear(BuildContext context, PrinterState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove printer?'),
        content: const Text(
          'This clears the saved printer on this device. It does not unpair '
          'the printer in Android settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(printerControllerProvider.notifier).clearConfig();
    if (!mounted) {
      return;
    }
    setState(() {
      _seeded = false;
      _deviceNameController.clear();
      _addressController.clear();
    });
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _CandidateNotice extends StatelessWidget {
  const _CandidateNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PosColors.warningSoft,
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.science_outlined, color: PosColors.warning),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hardware candidate, not verified on this project. Bluetooth '
                'Classic, LAN and USB adapters exist, but physical printing is '
                'not verified for any model. LAN framing is validated against a '
                'local TCP listener; Bluetooth and USB hardware remain PENDING '
                'until a real printer and Android device are tested.',
                style: TextStyle(color: PosColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstRunCard extends StatelessWidget {
  const _FirstRunCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No printer configured yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              '1. Choose Bluetooth Classic, LAN or USB.\n'
              '2. Enter the address (pair Bluetooth first, or use host:port for '
              'LAN / the device id for USB).\n'
              '3. Save, connect, then run Test print.',
              style: TextStyle(color: PosColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.state});

  final PrinterState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (state.status) {
      PrinterConnectionStatus.connected => PosColors.success,
      PrinterConnectionStatus.connecting => PosColors.warning,
      PrinterConnectionStatus.disconnected => PosColors.muted,
      PrinterConnectionStatus.unconfigured => PosColors.muted,
    };
    final background = switch (state.status) {
      PrinterConnectionStatus.connected => PosColors.successSoft,
      PrinterConnectionStatus.connecting => PosColors.warningSoft,
      PrinterConnectionStatus.disconnected => PosColors.surfaceMuted,
      PrinterConnectionStatus.unconfigured => PosColors.surfaceMuted,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    state.statusLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (state.busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (state.config != null) ...[
              const SizedBox(height: 10),
              Text(
                state.config!.connection.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${state.config!.transport.label} · '
                '${state.config!.connection.address} · '
                '${state.config!.paperWidth.label} · '
                '${state.config!.encoding.label}',
                style: const TextStyle(color: PosColors.muted, fontSize: 13),
              ),
            ],
            if (state.failureKind != null) ...[
              const SizedBox(height: 12),
              _FailureBanner(
                kind: state.failureKind!,
                message: state.message,
                onRetry: () => _retry(ref, state),
              ),
            ] else if (state.message != null) ...[
              const SizedBox(height: 10),
              Text(
                state.message!,
                style: const TextStyle(color: PosColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _retry(WidgetRef ref, PrinterState state) {
    final controller = ref.read(printerControllerProvider.notifier);
    if (state.failureKind == PrinterFailureKind.permissionDenied) {
      controller.requestPermissions();
      return;
    }
    if (state.status == PrinterConnectionStatus.connected) {
      controller.testPrint();
      return;
    }
    controller.connect();
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({
    required this.kind,
    required this.onRetry,
    this.message,
  });

  final PrinterFailureKind kind;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PosColors.dangerSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PosColors.danger),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: PosColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(kind),
                    style: const TextStyle(
                      color: PosColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message ?? _fallback(kind),
                    style: const TextStyle(color: PosColors.danger),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(PrinterFailureKind kind) {
    return switch (kind) {
      PrinterFailureKind.permissionDenied => 'Permission needed',
      PrinterFailureKind.bluetoothDisabled => 'Bluetooth is off',
      PrinterFailureKind.bluetoothUnsupported => 'Bluetooth unavailable',
      PrinterFailureKind.deviceNotFound => 'Printer not found',
      PrinterFailureKind.connectionLost => 'Connection lost',
      PrinterFailureKind.printRejected => 'Print rejected',
      PrinterFailureKind.unsupportedTransport => 'Transport not verified',
      PrinterFailureKind.notConnected => 'Not connected',
      PrinterFailureKind.unknown => 'Printer error',
    };
  }

  String _fallback(PrinterFailureKind kind) {
    return PrinterException(kind, '').userMessage;
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: granted ? PosColors.successSoft : PosColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle_outline : Icons.lock_outline,
            color: granted ? PosColors.success : PosColors.muted,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            granted ? 'Bluetooth permission granted' : 'Permission missing',
            style: TextStyle(
              color: granted ? PosColors.success : PosColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrinterLoadError extends StatelessWidget {
  const _PrinterLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: PosColors.danger),
            const SizedBox(height: 12),
            Text(
              'Could not load printer settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'The saved configuration could not be read on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PosColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
