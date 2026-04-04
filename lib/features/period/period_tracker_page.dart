import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/utils/app_formatters.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeriodTrackerPage extends ConsumerWidget {
  const PeriodTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Period Tracker')),
      body: appState.when(
        data: (state) {
          final profile = state.viewedProfile;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          final cycles = state.cycleEntries
              .where((entry) => entry.profileId == profile.id)
              .toList()
            ..sort((a, b) => b.cycleStart.compareTo(a.cycleStart));

          final latest = cycles.isEmpty ? null : cycles.first;
          final nextPeriod =
              latest == null ? null : latest.cycleStart.add(Duration(days: latest.cycleLength));
          final ovulation =
              nextPeriod == null ? null : nextPeriod.subtract(const Duration(days: 14));
          final fertileStart =
              ovulation == null ? null : ovulation.subtract(const Duration(days: 2));
          final fertileEnd =
              ovulation == null ? null : ovulation.add(const Duration(days: 2));
          final progress = latest == null
              ? 0.0
              : (DateTime.now().difference(latest.cycleStart).inDays / latest.cycleLength)
                  .clamp(0, 1)
                  .toDouble();

          return AmbientPage(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '${profile.name}\'s cycle',
                  subtitle: 'Private tracking with visual predictions for the next window.',
                  trailing: TextButton.icon(
                    onPressed: () => _showCycleEditor(context, ref, latest),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Update'),
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest == null ? 'No cycle data yet' : '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        latest == null ? 'Add a cycle entry to see predictions.' : 'Current cycle progress',
                      ),
                      const SizedBox(height: 16),
                      ProgressBar(
                        label: 'Cycle position',
                        value: progress,
                        color: Theme.of(context).colorScheme.primary,
                        trailing:
                            latest == null ? 'Waiting' : '${latest.cycleLength} day cycle',
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
                        title: 'Predictions',
                        subtitle: 'Simple offline estimation based on the latest entry.',
                      ),
                      const SizedBox(height: 14),
                      if (latest == null)
                        const Text('Predictions will appear after the first cycle record.')
                      else ...[
                        StatPill(
                          label: 'Next period',
                          value: formatFullDate(nextPeriod!),
                        ),
                        const SizedBox(height: 10),
                        StatPill(
                          label: 'Ovulation',
                          value: formatFullDate(ovulation!),
                        ),
                        const SizedBox(height: 10),
                        StatPill(
                          label: 'Fertile window',
                          value:
                              '${formatDayMonth(fertileStart!)} - ${formatDayMonth(fertileEnd!)}',
                        ),
                        if ((latest.symptoms ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Latest notes: ${latest.symptoms}'),
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
      ),
    );
  }

  Future<void> _showCycleEditor(
    BuildContext context,
    WidgetRef ref,
    CycleEntry? latest,
  ) async {
    DateTime cycleStart = latest?.cycleStart ?? DateTime.now();
    final cycleLengthController =
        TextEditingController(text: '${latest?.cycleLength ?? 28}');
    final periodLengthController =
        TextEditingController(text: '${latest?.periodLength ?? 5}');
    final symptomsController = TextEditingController(text: latest?.symptoms ?? '');

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
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: cycleStart,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSheetState(() => cycleStart = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Cycle start'),
                        child: Text(formatFullDate(cycleStart)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cycleLengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cycle length'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: periodLengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Period length'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: symptomsController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes / symptoms'),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Save cycle',
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        await ref.read(appControllerProvider.notifier).saveCycle(
                              cycleStart: cycleStart,
                              cycleLength: int.tryParse(cycleLengthController.text) ?? 28,
                              periodLength: int.tryParse(periodLengthController.text) ?? 5,
                              symptoms: symptomsController.text.trim().isEmpty
                                  ? null
                                  : symptomsController.text.trim(),
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
      cycleLengthController.dispose();
      periodLengthController.dispose();
      symptomsController.dispose();
    }
  }
}
