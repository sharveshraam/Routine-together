import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.workouts.where((w) => w.userId == state.activeUser.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: logs.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: e.value.durationMinutes.toDouble())],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: logs
                    .map((w) => ListTile(
                          leading: const Icon(Icons.directions_run),
                          title: Text(w.type),
                          subtitle: Text('${w.durationMinutes} minutes'),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
