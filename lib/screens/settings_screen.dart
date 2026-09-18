import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            trailing: Text('System'),
          ),
          ListTile(
            leading: Icon(Icons.headphones_outlined),
            title: Text('Audio quality'),
            trailing: Text('High'),
          ),
          ListTile(
            leading: Icon(Icons.download_outlined),
            title: Text('Offline downloads'),
            trailing: Text('Enabled'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('About'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
