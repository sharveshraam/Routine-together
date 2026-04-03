import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final personal = state.notes.where((n) => !n.forPartner).toList();
    final partner = state.notes.where((n) => n.forPartner).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          bottom: const TabBar(tabs: [Tab(text: 'Personal'), Tab(text: 'Partner Notes')]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => state.addNote('A new note from ${state.activeUser.name}', forPartner: false),
          icon: const Icon(Icons.note_add),
          label: const Text('Add Note'),
        ),
        body: TabBarView(
          children: [
            _list(personal),
            _list(partner),
          ],
        ),
      ),
    );
  }

  Widget _list(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No notes yet'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map((n) => Card(child: ListTile(leading: const Icon(Icons.note), title: Text(n.content))))
          .toList(),
    );
  }
}
