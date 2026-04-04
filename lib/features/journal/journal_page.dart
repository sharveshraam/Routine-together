import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/utils/app_formatters.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final profile = state.viewedProfile;
        if (profile == null) {
          return const SizedBox.shrink();
        }

        final entries = state.journalEntries
            .where((entry) => entry.profileId == profile.id)
            .toList()
          ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

        return AmbientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: '${profile.name}\'s journal',
                subtitle:
                    'A timeline mind map for memories, flashbacks, and emotional snapshots.',
                trailing: TextButton.icon(
                  onPressed: () => _showComposer(context, ref),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Write'),
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Relationship timeline map',
                      subtitle: 'Tap a node to open the entry behind that memory.',
                    ),
                    const SizedBox(height: 16),
                    MindMapView(
                      entries: entries.reversed.toList(),
                      onNodeTap: (entry) => _showEntryDialog(context, entry),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (entries.length > 1) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Flashbacks',
                        subtitle: 'Quick replays from older checkpoints.',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 142,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final entry = entries.skip(1).take(3).toList()[index];
                            return SizedBox(
                              width: 220,
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MoodChip(
                                      label: entry.mood,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      entry.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const Spacer(),
                                    Text(entry.highlight),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemCount: entries.skip(1).take(3).length,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
              for (final entry in entries) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MoodChip(
                            label: entry.mood,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(formatFullDate(entry.entryDate)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(entry.highlight),
                      const SizedBox(height: 10),
                      Text(entry.body),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (entries.isEmpty)
                const GlassCard(
                  child: Text('No journal entries yet. Start the timeline with the first note.'),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }

  Future<void> _showComposer(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final highlightController = TextEditingController();
    final bodyController = TextEditingController();
    String mood = 'Warm';

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: highlightController,
                      decoration: const InputDecoration(
                        labelText: 'Highlight sentence',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Story'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: mood,
                      items: const [
                        DropdownMenuItem(value: 'Warm', child: Text('Warm')),
                        DropdownMenuItem(value: 'Hopeful', child: Text('Hopeful')),
                        DropdownMenuItem(value: 'Light', child: Text('Light')),
                        DropdownMenuItem(value: 'Soft', child: Text('Soft')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => mood = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Save memory',
                      icon: Icons.favorite_rounded,
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty ||
                            bodyController.text.trim().isEmpty) {
                          return;
                        }
                        await ref.read(appControllerProvider.notifier).addJournalEntry(
                              title: titleController.text.trim(),
                              mood: mood,
                              body: bodyController.text.trim(),
                              highlight: highlightController.text.trim().isEmpty
                                  ? titleController.text.trim()
                                  : highlightController.text.trim(),
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      titleController.dispose();
      highlightController.dispose();
      bodyController.dispose();
    }
  }

  Future<void> _showEntryDialog(BuildContext context, JournalEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatFullDate(entry.entryDate)),
              const SizedBox(height: 12),
              Text(entry.highlight),
              const SizedBox(height: 12),
              Text(entry.body),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
