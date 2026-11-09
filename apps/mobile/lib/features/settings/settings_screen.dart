import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.dns_outlined),
            title: Text('Connection'),
            subtitle: Text('Configured at build time with API_BASE_URL.'),
          ),
        ),
      ],
    );
  }
}
