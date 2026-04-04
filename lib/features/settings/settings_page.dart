import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core\widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final current = state.currentProfile;
        final partner = state.partnerProfile;
        if (current == null) {
          return const SizedBox.shrink();
        }

        return AmbientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Settings',
                subtitle:
                    'Local pairing, encrypted backups, and Google Drive media sync live here.',
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Pairing codes',
                      subtitle:
                          'Your own code is generated locally. Use the input below after importing a partner bundle.',
                    ),
                    const SizedBox(height: 14),
                    StatPill(label: 'Your code', value: current.pairingCode),
                    if (partner != null) ...[
                      const SizedBox(height: 10),
                      StatPill(label: 'Partner code', value: partner.pairingCode),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showConnectCodeDialog(context, ref),
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Connect imported partner by code'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Encrypted backup',
                      subtitle:
                          'Export every local table as one password-protected backup file, then restore it on another device.',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportBackup(context, ref),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Export'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _importBackup(context, ref),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Import'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Google Drive media',
                      subtitle:
                          'Only media uses the cloud. Habit, journal, and note data stay local.',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _connectGoogle(context, ref),
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Connect Google'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _uploadMedia(context, ref),
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Upload media'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.mediaAssets.isEmpty)
                      const Text('No media synced yet.')
                    else
                      for (final asset in state.mediaAssets.take(3)) ...[
                        Row(
                          children: [
                            const Icon(Icons.image_outlined),
                            const SizedBox(width: 10),
                            Expanded(child: Text(p.basename(asset.localPath))),
                            Text(asset.driveFileId == null ? 'Local only' : 'Drive linked'),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }

  Future<void> _connectGoogle(BuildContext context, WidgetRef ref) async {
    try {
      final email = await ref.read(appControllerProvider.notifier).connectGoogleDrive();
      if (!context.mounted) {
        return;
      }
      final message = email == null
          ? 'Google sign-in was cancelled or still needs OAuth setup.'
          : 'Connected as $email';
      _showMessage(context, message);
    } catch (error) {
      _showMessage(context, error.toString());
    }
  }

  Future<void> _uploadMedia(BuildContext context, WidgetRef ref) async {
    try {
      final driveId = await ref.read(appControllerProvider.notifier).uploadMediaToDrive();
      if (!context.mounted) {
        return;
      }
      _showMessage(
        context,
        driveId == null ? 'No media uploaded.' : 'Uploaded media with Drive id $driveId',
      );
    } catch (error) {
      _showMessage(context, error.toString());
    }
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final password = await _askSecret(
      context,
      title: 'Export backup',
      hint: 'Enter a password for the encrypted file',
    );
    if (password == null || password.isEmpty) {
      return;
    }

    try {
      final file = await ref.read(appControllerProvider.notifier).exportBackup(password);
      if (!context.mounted || file == null) {
        return;
      }
      _showMessage(context, 'Backup saved to ${file.path}');
    } catch (error) {
      _showMessage(context, error.toString());
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final password = await _askSecret(
      context,
      title: 'Import backup',
      hint: 'Enter the password used during export',
    );
    if (password == null || password.isEmpty) {
      return;
    }

    try {
      await ref.read(appControllerProvider.notifier).importBackup(password);
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Backup imported successfully.');
    } catch (error) {
      _showMessage(context, error.toString());
    }
  }

  Future<void> _showConnectCodeDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Connect partner code'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Partner code',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(appControllerProvider.notifier)
                        .connectPartnerCode(controller.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (error) {
                    if (context.mounted) {
                      _showMessage(context, error.toString());
                    }
                  }
                },
                child: const Text('Connect'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  Future<String?> _askSecret(
    BuildContext context, {
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    try {
      return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(labelText: hint),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
