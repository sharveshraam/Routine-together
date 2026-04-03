import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_data.dart';
import '../models/entities.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  final _backupService = BackupService();

  bool partnerView = false;
  int navIndex = 0;

  late AppUser user;
  late AppUser partner;

  List<Habit> habits = [];
  List<WorkoutLog> workouts = [];
  List<JournalEntry> journals = [];
  List<NoteItem> notes = [];

  Future<void> bootstrap() async {
    await DatabaseService.instance.db;
    user = AppUser(id: 'u1', name: 'You', email: 'you@example.com', partnerCode: 'U1-A92K');
    partner = AppUser(id: 'u2', name: 'Partner', email: 'partner@example.com', partnerCode: 'U2-M4PX');
    habits = [...sampleHabits];
    workouts = [...sampleWorkouts];
    journals = [...sampleJournals];
    notes = [];
    notifyListeners();
  }

  AppUser get activeUser => partnerView ? partner : user;
  AppUser get passiveUser => partnerView ? user : partner;

  void toggleView() {
    partnerView = !partnerView;
    notifyListeners();
  }

  void setTab(int i) {
    navIndex = i;
    notifyListeners();
  }

  void addHabit(String title) {
    habits.add(
      Habit(id: _uuid.v4(), userId: activeUser.id, title: title, streak: 0, isDoneToday: false),
    );
    notifyListeners();
  }

  void addNote(String content, {required bool forPartner}) {
    notes.add(NoteItem(id: _uuid.v4(), userId: activeUser.id, content: content, forPartner: forPartner));
    notifyListeners();
  }

  Future<File> exportBackup(String password) => _backupService.exportEncryptedBackup(password);
}
