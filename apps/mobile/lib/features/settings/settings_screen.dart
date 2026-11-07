import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.dns_outlined),
            title: Text('Connection'),
            subtitle: Text('Configured at build time with API_BASE_URL.'),
          ),
        ),
      ),
    );
  }
}
