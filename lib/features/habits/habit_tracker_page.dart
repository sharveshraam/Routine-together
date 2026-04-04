import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitTrackerPage extends ConsumerWidget {
  const HabitTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      body: appState.when(
        data: (state) {
          final profile = state.viewedProfile;
          if (profile == null) {
            return const SizedBox.shrink();
          }
          final habits = state.habits.where((item) => item.profileId == profile.id).toList();

          return AmbientPage(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '${profile.name}\'s habits',
                  subtitle: 'Track daily consistency and let your partner see the rhythm.',
                  trailing: TextButton.icon(
                    onPressed: () => _showAddHabitSheet(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatPill(label: 'Active habits', value: '${habits.length}'),
                    StatPill(
                      label: 'Longest streak',
                      value: habits.isEmpty
                          ? '0'
                          : '${habits.map((e) => e.streak).reduce((a, b) => a > b ? a : b)} days',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (habits.isEmpty)
                  const GlassCard(
                    child: Text('No habits yet. Add the first ritual for this view.'),
                  ),
                for (final habit in habits) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text('${habit.streak} day streak'),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            ref.read(appControllerProvider.notifier).toggleHabit(habit);
                          },
                          icon: Icon(
                            _completedToday(state, habit)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                          ),
                        ),
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
      ),
    );
  }

  bool _completedToday(AppState state, Habit habit) {
    final today = DateTime.now();
    return state.habitLogs.any((log) {
      return log.habitId == habit.id &&
          log.completed &&
          log.logDate.year == today.year &&
          log.logDate.month == today.month &&
          log.logDate.day == today.day;
    });
  }

  Future<void> _showAddHabitSheet(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final iconController = TextEditingController(text: '✨');
    final colors = ['#F06A61', '#2D978E', '#BF8666', '#5967D8'];
    var selectedColor = colors.first;

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
                      decoration: const InputDecoration(labelText: 'Habit title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: iconController,
                      decoration: const InputDecoration(labelText: 'Emoji / icon'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (final color in colors)
                          ChoiceChip(
                            label: Text(color.replaceFirst('#', '')),
                            selected: selectedColor == color,
                            onSelected: (_) {
                              setSheetState(() => selectedColor = color);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Save habit',
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          return;
                        }
                        await ref.read(appControllerProvider.notifier).addHabit(
                              title: titleController.text.trim(),
                              icon: iconController.text.trim().isEmpty
                                  ? '✨'
                                  : iconController.text.trim(),
                              colorHex: selectedColor,
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
      iconController.dispose();
    }
  }
}
