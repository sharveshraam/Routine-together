import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    required this.onOpenHabits,
    required this.onOpenWorkouts,
    required this.onOpenJournal,
    required this.onOpenGrowth,
    required this.onOpenNotes,
    required this.onOpenPeriod,
  });

  final VoidCallback onOpenHabits;
  final VoidCallback onOpenWorkouts;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenGrowth;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenPeriod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final profile = state.viewedProfile;
        final partner = state.partnerProfile;
        if (profile == null || state.currentProfile == null) {
          return const SizedBox.shrink();
        }

        final habits = state.habits.where((item) => item.profileId == profile.id).toList();
        final workouts =
            state.workouts.where((item) => item.profileId == profile.id).toList();
        final entries = state.journalEntries
            .where((item) => item.profileId == profile.id)
            .toList()
          ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
        final latestEntry = entries.isEmpty ? null : entries.first;

        return AmbientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Hello, ${profile.name}',
                subtitle:
                    'Shared rhythm, gentle accountability, and a live glance into your couple space.',
              ),
              const SizedBox(height: 16),
              DuoAvatarHeader(
                currentProfile: state.currentProfile!,
                partnerProfile: partner,
                daysTogether: state.daysTogether,
                perspective: state.perspective,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatPill(label: 'Habits', value: '${habits.length} active'),
                  StatPill(label: 'Workouts', value: '${workouts.length} logged'),
                  StatPill(label: 'Memories', value: '${entries.length} entries'),
                ],
              ),
              const SizedBox(height: 22),
              const SectionTitle(
                title: 'Explore',
                subtitle: 'Cards open full experiences across routine, memories, and wellbeing.',
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: [
                  FeatureTile(
                    title: 'Habit Tracker',
                    subtitle: 'Daily checklist and streaks',
                    icon: Icons.check_circle_outline_rounded,
                    colors: const [Color(0xFFF06A61), Color(0xFFFFA37D)],
                    onTap: onOpenHabits,
                  ),
                  FeatureTile(
                    title: 'Workout Tracker',
                    subtitle: 'Weekly progress and sessions',
                    icon: Icons.fitness_center_rounded,
                    colors: const [Color(0xFF2D978E), Color(0xFF65C5B8)],
                    onTap: onOpenWorkouts,
                  ),
                  FeatureTile(
                    title: 'Journal',
                    subtitle: 'Mind map timeline and entries',
                    icon: Icons.device_hub_rounded,
                    colors: const [Color(0xFFBF8666), Color(0xFFE2B98A)],
                    onTap: onOpenJournal,
                  ),
                  FeatureTile(
                    title: 'Notes',
                    subtitle: 'Personal thoughts and partner notes',
                    icon: Icons.sticky_note_2_rounded,
                    colors: const [Color(0xFF5967D8), Color(0xFF94A2FF)],
                    onTap: onOpenNotes,
                  ),
                  FeatureTile(
                    title: 'Period Tracker',
                    subtitle: 'Cycle, ovulation, and predictions',
                    icon: Icons.water_drop_outlined,
                    colors: const [Color(0xFFE35D7B), Color(0xFFFFA6B6)],
                    onTap: onOpenPeriod,
                  ),
                  FeatureTile(
                    title: 'Growth Progress',
                    subtitle: 'Days together and comparison bars',
                    icon: Icons.show_chart_rounded,
                    colors: const [Color(0xFF2F4858), Color(0xFF6A8A9B)],
                    onTap: onOpenGrowth,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Today focus',
                      subtitle: 'Tap habits here for a quick check-in from home.',
                    ),
                    const SizedBox(height: 16),
                    if (habits.isEmpty)
                      const Text('No habits yet for this profile view.')
                    else
                      for (final habit in habits.take(3))
                        _HomeHabitRow(
                          habit: habit,
                          completed: _completedToday(state, habit),
                          onTap: () {
                            ref.read(appControllerProvider.notifier).toggleHabit(habit);
                          },
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Relationship map preview',
                      subtitle: latestEntry == null
                          ? 'The journal mind map grows as you add memories.'
                          : 'Tap into the full journal to explore each node.',
                    ),
                    const SizedBox(height: 16),
                    MindMapView(
                      entries: entries.reversed.toList(),
                      compact: true,
                      onNodeTap: (_) => onOpenJournal(),
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
                      title: 'Memory flashback',
                      subtitle: 'A small reminder pulled from your shared timeline.',
                    ),
                    const SizedBox(height: 14),
                    if (latestEntry == null)
                      const Text(
                        'Write the first journal entry to unlock flashbacks here.',
                      )
                    else ...[
                      MoodChip(
                        label: latestEntry.mood,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        latestEntry.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(latestEntry.highlight),
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
}

class _HomeHabitRow extends StatelessWidget {
  const _HomeHabitRow({
    required this.habit,
    required this.completed,
    required this.onTap,
  });

  final Habit habit;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Text(habit.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.title),
                  const SizedBox(height: 2),
                  Text(
                    '${habit.streak} day streak',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: completed
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
