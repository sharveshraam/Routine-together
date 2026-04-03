import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final togetherSince = DateTime(2025, 1, 1);
    final daysTogether = DateTime.now().difference(togetherSince).inDays;

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Days Together: $daysTogether', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _bar('You', 0.78),
            const SizedBox(height: 10),
            _bar('Partner', 0.70),
            const SizedBox(height: 24),
            Text('Memory Flashbacks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: state.journals.length,
                itemBuilder: (_, i) {
                  final j = state.journals[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.auto_awesome),
                      title: Text(j.title),
                      subtitle: Text(j.content),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(value: value, minHeight: 16),
        ),
      ],
    );
  }
}
