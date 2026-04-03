import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final habits = state.habits.where((h) => h.userId == state.activeUser.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => state.addHabit('New Habit ${habits.length + 1}'),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        itemBuilder: (_, i) {
          final h = habits[i];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: Icon(h.isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked),
                title: Text(h.title),
                subtitle: Text('Streak: ${h.streak} days'),
                trailing: const Icon(Icons.local_fire_department, color: Colors.orange),
              ),
            ),
          );
        },
      ),
    );
  }
}
