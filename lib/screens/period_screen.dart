import 'package:flutter/material.dart';

class PeriodScreen extends StatelessWidget {
  const PeriodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lastPeriod = DateTime.now().subtract(const Duration(days: 10));
    final nextPeriod = lastPeriod.add(const Duration(days: 28));
    final ovulation = lastPeriod.add(const Duration(days: 14));

    return Scaffold(
      appBar: AppBar(title: const Text('Period Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _timeline('Last period start', lastPeriod),
            _timeline('Predicted ovulation', ovulation),
            _timeline('Predicted next period', nextPeriod),
            const SizedBox(height: 20),
            const Text('Cycle visualization'),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(value: 10 / 28, minHeight: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeline(String title, DateTime value) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.circle_outlined),
        title: Text(title),
        subtitle: Text('${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'),
      ),
    );
  }
}
