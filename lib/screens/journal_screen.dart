import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final journals = context.watch<AppState>().journals;

    return Scaffold(
      appBar: AppBar(title: const Text('Journal Mind Map')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: expanded ? 260 : 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: journals.asMap().entries.map((entry) {
                    final i = entry.key;
                    final j = entry.value;
                    return Positioned(
                      left: 20 + i * 120,
                      top: expanded ? (i.isEven ? 40 : 130) : 44,
                      child: Column(
                        children: [
                          const CircleAvatar(radius: 12, child: Icon(Icons.circle, size: 10)),
                          const SizedBox(height: 4),
                          Text(DateFormat('MMM d').format(j.date)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Tap any node card below to open full entry:'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: journals
                    .map(
                      (j) => Card(
                        child: ListTile(
                          title: Text(j.title),
                          subtitle: Text(j.content),
                          trailing: Text(DateFormat('yyyy-MM-dd').format(j.date)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
