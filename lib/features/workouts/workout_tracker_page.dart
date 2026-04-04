import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/utils/app_formatters.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutTrackerPage extends ConsumerWidget {
  const WorkoutTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: appState.when(
        data: (state) {
          final profile = state.viewedProfile;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          final workouts =
              state.workouts.where((item) => item.profileId == profile.id).toList();
          final bars = _weeklyMinutes(workouts);

          return AmbientPage(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '${profile.name}\'s workouts',
                  subtitle: 'Quick logging with a simple weekly visual.',
                  trailing: TextButton.icon(
                    onPressed: () => _showAddWorkoutSheet(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Log'),
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This week'),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 170,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: bars.entries.map((entry) {
                            final maxMinutes =
                                bars.values.fold<int>(1, (a, b) => a > b ? a : b);
                            final factor = entry.value / maxMinutes;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('${entry.value}m'),
                                    const SizedBox(height: 8),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 260),
                                      height: 24 + (100 * factor),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Theme.of(context).colorScheme.secondary,
                                            Theme.of(context).colorScheme.primary,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(entry.key),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (workouts.isEmpty)
                  const GlassCard(
                    child: Text('No workouts logged yet for this profile view.'),
                  ),
                for (final workout in workouts) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary.withOpacity(0.14),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workout.minutes} mins - intensity ${workout.intensity}/5 - ${formatFullDate(workout.workoutDate)}',
                              ),
                              if (workout.note != null) ...[
                                const SizedBox(height: 6),
                                Text(workout.note!),
                              ],
                            ],
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

  Map<String, int> _weeklyMinutes(List<WorkoutSession> workouts) {
    final now = DateTime.now();
    final result = <String, int>{};
    for (var offset = 6; offset >= 0; offset--) {
      final day = DateTime(now.year, now.month, now.day - offset);
      final label = formatWeekday(day);
      final minutes = workouts
          .where((workout) =>
              workout.workoutDate.year == day.year &&
              workout.workoutDate.month == day.month &&
              workout.workoutDate.day == day.day)
          .fold<int>(0, (sum, workout) => sum + workout.minutes);
      result[label] = minutes;
    }
    return result;
  }

  Future<void> _showAddWorkoutSheet(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final minutesController = TextEditingController(text: '30');
    double intensity = 3;

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
                      decoration: const InputDecoration(labelText: 'Workout name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minutes'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Optional note'),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intensity ${intensity.round()}/5'),
                        Slider(
                          min: 1,
                          max: 5,
                          value: intensity,
                          onChanged: (value) {
                            setSheetState(() => intensity = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: 'Log workout',
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          return;
                        }
                        await ref.read(appControllerProvider.notifier).addWorkout(
                              title: titleController.text.trim(),
                              minutes: int.tryParse(minutesController.text) ?? 30,
                              intensity: intensity.round(),
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
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
      noteController.dispose();
      minutesController.dispose();
    }
  }
}
