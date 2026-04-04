import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/utils/app_formatters.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({
    super.key,
    required this.onOpenPeriod,
  });

  final VoidCallback onOpenPeriod;

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  NoteType _selected = NoteType.personal;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final current = state.currentProfile;
        final partner = state.partnerProfile;
        if (current == null) {
          return const SizedBox.shrink();
        }

        final notes = state.notes.where((note) {
          if (_selected == NoteType.personal) {
            return note.type == NoteType.personal &&
                note.profileId == state.viewedProfile?.id;
          }
          return note.type == NoteType.partner &&
              (note.profileId == current.id || note.recipientProfileId == current.id);
        }).toList();

        return AmbientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: _selected == NoteType.personal ? 'Notes' : 'Partner notes',
                subtitle:
                    'Keep private thoughts or drop a warm message into the shared relationship space.',
                trailing: TextButton.icon(
                  onPressed: () => _showComposer(context),
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<NoteType>(
                segments: const [
                  ButtonSegment(
                    value: NoteType.personal,
                    icon: Icon(Icons.lock_outline_rounded),
                    label: Text('Personal'),
                  ),
                  ButtonSegment(
                    value: NoteType.partner,
                    icon: Icon(Icons.favorite_border_rounded),
                    label: Text('Partner'),
                  ),
                ],
                selected: {_selected},
                onSelectionChanged: (value) {
                  setState(() => _selected = value.first);
                },
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wellbeing side quest',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Open the period tracker to update predictions and cycle context.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: widget.onOpenPeriod,
                      icon: const Icon(Icons.water_drop_outlined),
                      label: const Text('Open'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_selected == NoteType.partner && partner != null)
                GlassCard(
                  child: Text(
                    'Messages sent to ${partner.name} stay visible here as a soft shared feed.',
                  ),
                ),
              if (_selected == NoteType.partner && partner != null)
                const SizedBox(height: 18),
              if (notes.isEmpty)
                const GlassCard(
                  child: Text('Nothing here yet. Write the first note or partner message.'),
                ),
              for (final note in notes) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MoodChip(
                            label: note.type == NoteType.personal ? 'Personal' : 'Partner',
                            color: note.type == NoteType.personal
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 10),
                          Text(formatFullDate(note.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(note.body),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }

  Future<void> _showComposer(BuildContext context) async {
    final controller = TextEditingController();
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
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
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: _selected == NoteType.personal
                        ? 'Write a personal note'
                        : 'Leave a note for your partner',
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Save note',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }
                    await ref.read(appControllerProvider.notifier).addNote(
                          body: controller.text.trim(),
                          type: _selected,
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
    } finally {
      controller.dispose();
    }
  }
}
