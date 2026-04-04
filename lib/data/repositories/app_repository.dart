import 'dart:math';

import 'package:duobloom_mobile/data/database/app_database.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class AppRepository {
  AppRepository({
    required this.database,
    required this.uuid,
  });

  final AppDatabase database;
  final Uuid uuid;

  Future<List<AppProfile>> getProfiles() async {
    final db = await database.database;
    final rows = await db.query('profiles', orderBy: 'created_at ASC');
    return rows.map(AppProfile.fromMap).toList();
  }

  Future<List<Habit>> getHabits() async {
    final db = await database.database;
    final rows = await db.query('habits', orderBy: 'created_at ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<List<HabitLog>> getHabitLogs() async {
    final db = await database.database;
    final rows = await db.query('habit_logs', orderBy: 'log_date DESC');
    return rows.map(HabitLog.fromMap).toList();
  }

  Future<List<WorkoutSession>> getWorkouts() async {
    final db = await database.database;
    final rows = await db.query('workouts', orderBy: 'workout_date DESC');
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await database.database;
    final rows = await db.query('journal_entries', orderBy: 'entry_date DESC');
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<List<NoteItem>> getNotes() async {
    final db = await database.database;
    final rows = await db.query('notes', orderBy: 'created_at DESC');
    return rows.map(NoteItem.fromMap).toList();
  }

  Future<List<CycleEntry>> getCycleEntries() async {
    final db = await database.database;
    final rows = await db.query('cycle_entries', orderBy: 'cycle_start DESC');
    return rows.map(CycleEntry.fromMap).toList();
  }

  Future<List<MediaAsset>> getMediaAssets() async {
    final db = await database.database;
    final rows = await db.query('media_assets', orderBy: 'created_at DESC');
    return rows.map(MediaAsset.fromMap).toList();
  }

  Future<String?> getMeta(String key) async {
    final db = await database.database;
    final rows = await db.query(
      'app_meta',
      where: 'meta_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['meta_value'] as String;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await database.database;
    await db.insert(
      'app_meta',
      {
        'meta_key': key,
        'meta_value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createCouple({
    required OnboardingData data,
    required String? passwordHash,
    required String? googleEmail,
  }) async {
    final db = await database.database;
    final now = DateTime.now();
    final primaryId = uuid.v4();
    final partnerId = uuid.v4();

    final primary = AppProfile(
      id: primaryId,
      name: data.name.trim(),
      relationshipLabel: data.relationshipLabel.trim(),
      pairingCode: _generatePairingCode(data.name),
      avatarSeed: now.millisecond + 7,
      startDate: data.sinceDate,
      authMethod: data.authMethod,
      email: _clean(data.email),
      phone: _clean(data.phone),
      passwordHash: passwordHash,
      googleEmail: googleEmail,
      createdAt: now,
    );

    final partner = AppProfile(
      id: partnerId,
      name: data.partnerName.trim(),
      relationshipLabel: data.relationshipLabel.trim(),
      pairingCode:
          (_clean(data.partnerCode)?.toUpperCase()) ?? _generatePairingCode(data.partnerName),
      avatarSeed: now.microsecond + 19,
      startDate: data.sinceDate,
      authMethod: AuthMethod.email,
      createdAt: now,
    );

    final primaryHabits = _seedHabits(primaryId, now, _primaryHabitPalette);
    final partnerHabits = _seedHabits(partnerId, now, _partnerHabitPalette);

    final batch = db.batch();
    batch.insert('profiles', primary.toMap());
    batch.insert('profiles', partner.toMap());
    batch.insert(
      'app_meta',
      {
        'meta_key': AppMetaKey.currentProfileId.key,
        'meta_value': primaryId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.insert(
      'app_meta',
      {
        'meta_key': AppMetaKey.partnerProfileId.key,
        'meta_value': partnerId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    batch.insert(
      'app_meta',
      {
        'meta_key': AppMetaKey.viewPerspective.key,
        'meta_value': ViewPerspective.user.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final habit in [...primaryHabits, ...partnerHabits]) {
      batch.insert('habits', habit.toMap());
    }

    for (final log in [
      ..._seedHabitLogs(primaryHabits, now),
      ..._seedHabitLogs(partnerHabits, now),
    ]) {
      batch.insert('habit_logs', log.toMap());
    }

    for (final workout in _seedWorkouts(primaryId, now, true)) {
      batch.insert('workouts', workout.toMap());
    }
    for (final workout in _seedWorkouts(partnerId, now, false)) {
      batch.insert('workouts', workout.toMap());
    }

    for (final entry in _seedJournalEntries(primaryId, partnerId, now)) {
      batch.insert('journal_entries', entry.toMap());
    }

    for (final note in _seedNotes(primaryId, partnerId, now)) {
      batch.insert('notes', note.toMap());
    }

    batch.insert(
      'cycle_entries',
      CycleEntry(
        id: uuid.v4(),
        profileId: partnerId,
        cycleStart: now.subtract(const Duration(days: 10)),
        cycleLength: 29,
        periodLength: 5,
        symptoms: 'Energy dip, cramps, craving warm tea',
      ).toMap(),
    );

    await batch.commit(noResult: true);
  }

  Future<void> attachGoogleEmail(String profileId, String email) async {
    final db = await database.database;
    await db.update(
      'profiles',
      {'google_email': email},
      where: 'id = ?',
      whereArgs: [profileId],
    );
  }

  Future<void> addHabit({
    required String profileId,
    required String title,
    required String icon,
    required String colorHex,
  }) async {
    final db = await database.database;
    final habit = Habit(
      id: uuid.v4(),
      profileId: profileId,
      title: title,
      icon: icon,
      target: 1,
      streak: 0,
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );
    await db.insert('habits', habit.toMap());
  }

  Future<void> toggleHabitCompletion(Habit habit, DateTime timestamp) async {
    final db = await database.database;
    final day = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final isoDay = day.toIso8601String();
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habit.id, isoDay],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(
        'habit_logs',
        HabitLog(
          id: uuid.v4(),
          habitId: habit.id,
          logDate: day,
          completed: true,
        ).toMap(),
      );
    } else {
      final completed = (existing.first['completed']! as int) == 1;
      await db.update(
        'habit_logs',
        {'completed': completed ? 0 : 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }

    final logs = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND completed = 1',
      whereArgs: [habit.id],
      orderBy: 'log_date DESC',
    );

    final streak = _calculateStreak(logs.map(HabitLog.fromMap).toList());
    await db.update(
      'habits',
      {'streak': streak},
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> addWorkout({
    required String profileId,
    required String title,
    required int minutes,
    required int intensity,
    String? note,
  }) async {
    final db = await database.database;
    final workout = WorkoutSession(
      id: uuid.v4(),
      profileId: profileId,
      title: title,
      minutes: minutes,
      intensity: intensity,
      workoutDate: DateTime.now(),
      note: note,
    );
    await db.insert('workouts', workout.toMap());
  }

  Future<void> addJournalEntry({
    required String profileId,
    required String title,
    required String mood,
    required String body,
    required String highlight,
    String? mediaPath,
  }) async {
    final db = await database.database;
    final entry = JournalEntry(
      id: uuid.v4(),
      profileId: profileId,
      entryDate: DateTime.now(),
      title: title,
      mood: mood,
      body: body,
      highlight: highlight,
      mediaPath: mediaPath,
    );
    await db.insert('journal_entries', entry.toMap());
  }

  Future<void> addNote({
    required String authorProfileId,
    required NoteType type,
    required String body,
    String? recipientProfileId,
  }) async {
    final db = await database.database;
    final note = NoteItem(
      id: uuid.v4(),
      profileId: authorProfileId,
      type: type,
      body: body,
      createdAt: DateTime.now(),
      pinned: false,
      recipientProfileId: recipientProfileId,
    );
    await db.insert('notes', note.toMap());
  }

  Future<void> addCycleEntry({
    required String profileId,
    required DateTime cycleStart,
    required int cycleLength,
    required int periodLength,
    String? symptoms,
  }) async {
    final db = await database.database;
    final entry = CycleEntry(
      id: uuid.v4(),
      profileId: profileId,
      cycleStart: cycleStart,
      cycleLength: cycleLength,
      periodLength: periodLength,
      symptoms: symptoms,
    );
    await db.insert('cycle_entries', entry.toMap());
  }

  Future<void> addMediaAsset({
    required String profileId,
    required String localPath,
    String? driveFileId,
    String? journalEntryId,
  }) async {
    final db = await database.database;
    final asset = MediaAsset(
      id: uuid.v4(),
      profileId: profileId,
      localPath: localPath,
      driveFileId: driveFileId,
      journalEntryId: journalEntryId,
      createdAt: DateTime.now(),
    );
    await db.insert('media_assets', asset.toMap());
  }

  Future<void> connectPartnerCode({
    required String currentProfileId,
    required String code,
  }) async {
    final db = await database.database;
    final rows = await db.query(
      'profiles',
      where: 'pairing_code = ? AND id != ?',
      whereArgs: [code.trim().toUpperCase(), currentProfileId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError(
        'No local partner found for that code. Import the partner backup first.',
      );
    }

    await setMeta(
      AppMetaKey.partnerProfileId.key,
      rows.first['id']! as String,
    );
  }

  Future<Map<String, dynamic>> exportBundle() async {
    return database.exportAllTables();
  }

  Future<void> importBundle(Map<String, dynamic> bundle) async {
    await database.restoreAllTables(bundle);
  }

  int _calculateStreak(List<HabitLog> logs) {
    final completedDays = logs
        .where((log) => log.completed)
        .map((log) => DateTime(log.logDate.year, log.logDate.month, log.logDate.day))
        .toSet();

    var streak = 0;
    var cursor = DateTime.now();
    while (true) {
      final day = DateTime(cursor.year, cursor.month, cursor.day);
      if (!completedDays.contains(day)) {
        break;
      }
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String _generatePairingCode(String name) {
    final clean = name.trim().split(RegExp(r'\s+'));
    final prefix = clean.take(2).map((chunk) => chunk[0]).join().toUpperCase();
    final random = Random.secure().nextInt(899999) + 100000;
    return '$prefix$random';
  }

  String? _clean(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<Habit> _seedHabits(
    String profileId,
    DateTime now,
    List<_HabitSeed> seeds,
  ) {
    return seeds.map((seed) {
      return Habit(
        id: uuid.v4(),
        profileId: profileId,
        title: seed.title,
        icon: seed.icon,
        target: 1,
        streak: seed.streak,
        colorHex: seed.colorHex,
        createdAt: now.subtract(Duration(days: seed.offsetDays)),
      );
    }).toList();
  }

  List<HabitLog> _seedHabitLogs(List<Habit> habits, DateTime now) {
    final logs = <HabitLog>[];
    for (var index = 0; index < habits.length; index++) {
      final streak = habits[index].streak;
      for (var day = 0; day < streak; day++) {
        logs.add(
          HabitLog(
            id: uuid.v4(),
            habitId: habits[index].id,
            logDate: DateTime(now.year, now.month, now.day - day),
            completed: true,
          ),
        );
      }
    }
    return logs;
  }

  List<WorkoutSession> _seedWorkouts(
    String profileId,
    DateTime now,
    bool isPrimary,
  ) {
    final titles = isPrimary
        ? [
            ('Strength flow', 42, 4),
            ('Mobility reset', 26, 2),
            ('Morning walk', 31, 2),
          ]
        : [
            ('Pilates tone', 35, 3),
            ('Evening yoga', 28, 2),
            ('Core sculpt', 24, 4),
          ];

    return List.generate(titles.length, (index) {
      final item = titles[index];
      return WorkoutSession(
        id: uuid.v4(),
        profileId: profileId,
        title: item.$1,
        minutes: item.$2,
        intensity: item.$3,
        workoutDate: now.subtract(Duration(days: index * 2)),
        note: index == 0 ? 'Shared energy felt strong today.' : null,
      );
    });
  }

  List<JournalEntry> _seedJournalEntries(
    String primaryId,
    String partnerId,
    DateTime now,
  ) {
    return [
      JournalEntry(
        id: uuid.v4(),
        profileId: primaryId,
        entryDate: now.subtract(const Duration(days: 120)),
        title: 'First shared routine',
        mood: 'Warm',
        body:
            'We turned a rushed evening into a quiet walk and decided to build rhythms that feel like home.',
        highlight: 'We chose consistency over intensity.',
      ),
      JournalEntry(
        id: uuid.v4(),
        profileId: partnerId,
        entryDate: now.subtract(const Duration(days: 64)),
        title: 'Tiny wins week',
        mood: 'Light',
        body:
            'Our check-ins stayed playful, the workouts stayed short, and somehow everything felt easier.',
        highlight: 'Short sessions made us more consistent.',
      ),
      JournalEntry(
        id: uuid.v4(),
        profileId: primaryId,
        entryDate: now.subtract(const Duration(days: 9)),
        title: 'Reset day',
        mood: 'Hopeful',
        body:
            'We skipped perfection, wrote quick notes, and still came back to each other.',
        highlight: 'Coming back matters more than never missing.',
      ),
    ];
  }

  List<NoteItem> _seedNotes(
    String primaryId,
    String partnerId,
    DateTime now,
  ) {
    return [
      NoteItem(
        id: uuid.v4(),
        profileId: primaryId,
        type: NoteType.personal,
        body: 'Remember to prep fruit before the late workout block.',
        createdAt: now.subtract(const Duration(hours: 10)),
        pinned: true,
      ),
      NoteItem(
        id: uuid.v4(),
        profileId: primaryId,
        type: NoteType.partner,
        body: 'Proud of how you showed up even on the low-energy day.',
        createdAt: now.subtract(const Duration(hours: 4)),
        pinned: false,
        recipientProfileId: partnerId,
      ),
    ];
  }
}

class _HabitSeed {
  const _HabitSeed(
    this.title,
    this.icon,
    this.colorHex,
    this.streak,
    this.offsetDays,
  );

  final String title;
  final String icon;
  final String colorHex;
  final int streak;
  final int offsetDays;
}

const _primaryHabitPalette = [
  _HabitSeed('Hydration', '💧', '#F06A61', 5, 20),
  _HabitSeed('Read 10 mins', '📚', '#2D978E', 4, 18),
  _HabitSeed('Stretch', '🧘', '#BF8666', 2, 14),
];

const _partnerHabitPalette = [
  _HabitSeed('Skincare', '✨', '#FF8A65', 6, 16),
  _HabitSeed('Walk 6k', '👟', '#4DB6AC', 3, 15),
  _HabitSeed('Journal', '📝', '#D4A373', 4, 12),
];
