import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Receipt printer'),
            subtitle: const Text(
              'Configure a Bluetooth Classic printer and run a test print.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/printer'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Print queue'),
            subtitle: const Text(
              'Review queued, sent, failed and uncertain receipt jobs.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/print-queue'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Offline sales & sync'),
            subtitle: const Text(
              'Review pending, uncertain and conflict sales; retry encrypted '
              'sync and reconcile with server sales.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/offline-sync'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.dns_outlined),
            title: Text('API connection'),
            subtitle: Text('Configured at build time with API_BASE_URL.'),
          ),
        ),
      ],
    );
  }
}
