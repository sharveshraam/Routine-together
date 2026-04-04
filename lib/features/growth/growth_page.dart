import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GrowthPage extends ConsumerWidget {
  const GrowthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final user = state.currentProfile;
        final partner = state.partnerProfile;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final userScore = _growthScore(state, user.id);
        final partnerScore = partner == null ? 0.0 : _growthScore(state, partner.id);
        final userHabitCount =
            state.habits.where((item) => item.profileId == user.id).length;
        final partnerHabitCount = partner == null
            ? 0
            : state.habits.where((item) => item.profileId == partner.id).length;

        return AmbientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Growth Progress',
                subtitle:
                    'Days together, effort comparison, and the momentum building behind your routines.',
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.daysTogether}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    const Text('Days together'),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatPill(label: user.name, value: '${(userScore * 100).round()}%'),
                        if (partner != null)
                          StatPill(
                            label: partner.name,
                            value: '${(partnerScore * 100).round()}%',
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
                      title: 'Momentum bars',
                      subtitle:
                          'A blended score based on habit consistency, workouts, notes, and journals.',
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      label: user.name,
                      value: userScore,
                      color: Theme.of(context).colorScheme.primary,
                      trailing: '$userHabitCount habits',
                    ),
                    const SizedBox(height: 16),
                    if (partner != null)
                      ProgressBar(
                        label: partner.name,
                        value: partnerScore,
                        color: Theme.of(context).colorScheme.secondary,
                        trailing: '$partnerHabitCount habits',
                      ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      label: 'Shared rhythm',
                      value: ((userScore + partnerScore) / (partner == null ? 1 : 2)),
                      color: Theme.of(context).colorScheme.tertiary,
                      trailing: 'Couple sync',
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
                      title: 'Flashback markers',
                      subtitle: 'Moments that show how your rhythm has evolved.',
                    ),
                    const SizedBox(height: 14),
                    for (final entry in state.journalEntries.take(4)) ...[
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(entry.highlight),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (entry != state.journalEntries.take(4).last) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.5),
                          child: Container(
                            width: 1.5,
                            height: 26,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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

  double _growthScore(AppState state, String profileId) {
    final habits = state.habits.where((item) => item.profileId == profileId).toList();
    final workouts = state.workouts.where((item) => item.profileId == profileId).length;
    final journal = state.journalEntries.where((item) => item.profileId == profileId).length;
    final notes = state.notes.where((item) => item.profileId == profileId).length;

    final streakPoints = habits.fold<int>(0, (sum, habit) => sum + habit.streak);
    final raw = (streakPoints * 2) + (workouts * 4) + (journal * 6) + (notes * 3);
    return (raw / 100).clamp(0, 1).toDouble();
  }
}
