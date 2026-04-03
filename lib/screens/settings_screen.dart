import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../services/auth_service.dart';
import '../services/media_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final auth = AuthService();
  final mediaSync = MediaSyncService();
  String status = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Security & Media Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Your connection code'),
                subtitle: Text(state.user.partnerCode),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final file = await state.exportBackup('demo_password');
                setState(() => status = 'Encrypted backup exported: ${file.path}');
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Export Encrypted Backup'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                final account = await auth.signInWithGoogle();
                if (account != null) {
                  await mediaSync.syncMediaToDrive(account);
                  setState(() => status = 'Media sync completed for ${account.email}');
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Google Drive Media Sync'),
            ),
            const SizedBox(height: 16),
            Text(status),
          ],
        ),
      ),
    );
  }
}
