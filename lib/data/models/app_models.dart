enum ViewPerspective { user, partner }

enum AuthMethod { google, email, phone }

enum NoteType { personal, partner }

enum AppMetaKey {
  currentProfileId('current_profile_id'),
  partnerProfileId('partner_profile_id'),
  viewPerspective('view_perspective');

  const AppMetaKey(this.key);

  final String key;
}

class OnboardingData {
  const OnboardingData({
    required this.name,
    required this.partnerName,
    required this.relationshipLabel,
    required this.sinceDate,
    required this.authMethod,
    this.partnerCode,
    this.email,
    this.phone,
    this.password,
    this.googleEmail,
  });

  final String name;
  final String partnerName;
  final String relationshipLabel;
  final DateTime sinceDate;
  final AuthMethod authMethod;
  final String? partnerCode;
  final String? email;
  final String? phone;
  final String? password;
  final String? googleEmail;
}

class AppProfile {
  const AppProfile({
    required this.id,
    required this.name,
    required this.relationshipLabel,
    required this.pairingCode,
    required this.avatarSeed,
    required this.startDate,
    required this.authMethod,
    required this.createdAt,
    this.email,
    this.phone,
    this.passwordHash,
    this.googleEmail,
  });

  final String id;
  final String name;
  final String relationshipLabel;
  final String pairingCode;
  final int avatarSeed;
  final DateTime startDate;
  final AuthMethod authMethod;
  final String? email;
  final String? phone;
  final String? passwordHash;
  final String? googleEmail;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship_label': relationshipLabel,
      'pairing_code': pairingCode,
      'avatar_seed': avatarSeed,
      'start_date': startDate.toIso8601String(),
      'auth_method': authMethod.name,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'google_email': googleEmail,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppProfile.fromMap(Map<String, Object?> map) {
    return AppProfile(
      id: map['id']! as String,
      name: map['name']! as String,
      relationshipLabel: map['relationship_label']! as String,
      pairingCode: map['pairing_code']! as String,
      avatarSeed: map['avatar_seed']! as int,
      startDate: DateTime.parse(map['start_date']! as String),
      authMethod: AuthMethod.values.byName(map['auth_method']! as String),
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      passwordHash: map['password_hash'] as String?,
      googleEmail: map['google_email'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

class Habit {
  const Habit({
    required this.id,
    required this.profileId,
    required this.title,
    required this.icon,
    required this.target,
    required this.streak,
    required this.colorHex,
    required this.createdAt,
  });

  final String id;
  final String profileId;
  final String title;
  final String icon;
  final int target;
  final int streak;
  final String colorHex;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'title': title,
      'icon': icon,
      'target': target,
      'streak': streak,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    return Habit(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      title: map['title']! as String,
      icon: map['icon']! as String,
      target: map['target']! as int,
      streak: map['streak']! as int,
      colorHex: map['color_hex']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.logDate,
    required this.completed,
  });

  final String id;
  final String habitId;
  final DateTime logDate;
  final bool completed;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'log_date': logDate.toIso8601String(),
      'completed': completed ? 1 : 0,
    };
  }

  factory HabitLog.fromMap(Map<String, Object?> map) {
    return HabitLog(
      id: map['id']! as String,
      habitId: map['habit_id']! as String,
      logDate: DateTime.parse(map['log_date']! as String),
      completed: (map['completed']! as int) == 1,
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.profileId,
    required this.title,
    required this.minutes,
    required this.intensity,
    required this.workoutDate,
    this.note,
  });

  final String id;
  final String profileId;
  final String title;
  final int minutes;
  final int intensity;
  final DateTime workoutDate;
  final String? note;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'title': title,
      'minutes': minutes,
      'intensity': intensity,
      'workout_date': workoutDate.toIso8601String(),
      'note': note,
    };
  }

  factory WorkoutSession.fromMap(Map<String, Object?> map) {
    return WorkoutSession(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      title: map['title']! as String,
      minutes: map['minutes']! as int,
      intensity: map['intensity']! as int,
      workoutDate: DateTime.parse(map['workout_date']! as String),
      note: map['note'] as String?,
    );
  }
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.profileId,
    required this.entryDate,
    required this.title,
    required this.mood,
    required this.body,
    required this.highlight,
    this.mediaPath,
    this.driveFileId,
  });

  final String id;
  final String profileId;
  final DateTime entryDate;
  final String title;
  final String mood;
  final String body;
  final String highlight;
  final String? mediaPath;
  final String? driveFileId;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'entry_date': entryDate.toIso8601String(),
      'title': title,
      'mood': mood,
      'body': body,
      'highlight': highlight,
      'media_path': mediaPath,
      'drive_file_id': driveFileId,
    };
  }

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      entryDate: DateTime.parse(map['entry_date']! as String),
      title: map['title']! as String,
      mood: map['mood']! as String,
      body: map['body']! as String,
      highlight: map['highlight']! as String,
      mediaPath: map['media_path'] as String?,
      driveFileId: map['drive_file_id'] as String?,
    );
  }
}

class NoteItem {
  const NoteItem({
    required this.id,
    required this.profileId,
    required this.type,
    required this.body,
    required this.createdAt,
    required this.pinned,
    this.recipientProfileId,
  });

  final String id;
  final String profileId;
  final NoteType type;
  final String body;
  final DateTime createdAt;
  final bool pinned;
  final String? recipientProfileId;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'note_type': type.name,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'pinned': pinned ? 1 : 0,
      'recipient_profile_id': recipientProfileId,
    };
  }

  factory NoteItem.fromMap(Map<String, Object?> map) {
    return NoteItem(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      type: NoteType.values.byName(map['note_type']! as String),
      body: map['body']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      pinned: (map['pinned']! as int) == 1,
      recipientProfileId: map['recipient_profile_id'] as String?,
    );
  }
}

class CycleEntry {
  const CycleEntry({
    required this.id,
    required this.profileId,
    required this.cycleStart,
    required this.cycleLength,
    required this.periodLength,
    this.symptoms,
  });

  final String id;
  final String profileId;
  final DateTime cycleStart;
  final int cycleLength;
  final int periodLength;
  final String? symptoms;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'cycle_start': cycleStart.toIso8601String(),
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'symptoms': symptoms,
    };
  }

  factory CycleEntry.fromMap(Map<String, Object?> map) {
    return CycleEntry(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      cycleStart: DateTime.parse(map['cycle_start']! as String),
      cycleLength: map['cycle_length']! as int,
      periodLength: map['period_length']! as int,
      symptoms: map['symptoms'] as String?,
    );
  }
}

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.profileId,
    required this.localPath,
    required this.createdAt,
    this.driveFileId,
    this.journalEntryId,
  });

  final String id;
  final String profileId;
  final String localPath;
  final String? driveFileId;
  final String? journalEntryId;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'local_path': localPath,
      'drive_file_id': driveFileId,
      'journal_entry_id': journalEntryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MediaAsset.fromMap(Map<String, Object?> map) {
    return MediaAsset(
      id: map['id']! as String,
      profileId: map['profile_id']! as String,
      localPath: map['local_path']! as String,
      driveFileId: map['drive_file_id'] as String?,
      journalEntryId: map['journal_entry_id'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}

class AppState {
  const AppState({
    required this.profiles,
    required this.currentProfile,
    required this.partnerProfile,
    required this.perspective,
    required this.habits,
    required this.habitLogs,
    required this.workouts,
    required this.journalEntries,
    required this.notes,
    required this.cycleEntries,
    required this.mediaAssets,
  });

  factory AppState.empty() {
    return const AppState(
      profiles: [],
      currentProfile: null,
      partnerProfile: null,
      perspective: ViewPerspective.user,
      habits: [],
      habitLogs: [],
      workouts: [],
      journalEntries: [],
      notes: [],
      cycleEntries: [],
      mediaAssets: [],
    );
  }

  final List<AppProfile> profiles;
  final AppProfile? currentProfile;
  final AppProfile? partnerProfile;
  final ViewPerspective perspective;
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final List<WorkoutSession> workouts;
  final List<JournalEntry> journalEntries;
  final List<NoteItem> notes;
  final List<CycleEntry> cycleEntries;
  final List<MediaAsset> mediaAssets;

  bool get isOnboarded => currentProfile != null;

  AppProfile? get viewedProfile {
    if (perspective == ViewPerspective.partner) {
      return partnerProfile ?? currentProfile;
    }
    return currentProfile;
  }

  int get daysTogether {
    final start = currentProfile?.startDate;
    if (start == null) {
      return 0;
    }
    return DateTime.now().difference(start).inDays + 1;
  }

  AppState copyWith({
    List<AppProfile>? profiles,
    AppProfile? currentProfile,
    AppProfile? partnerProfile,
    ViewPerspective? perspective,
    List<Habit>? habits,
    List<HabitLog>? habitLogs,
    List<WorkoutSession>? workouts,
    List<JournalEntry>? journalEntries,
    List<NoteItem>? notes,
    List<CycleEntry>? cycleEntries,
    List<MediaAsset>? mediaAssets,
  }) {
    return AppState(
      profiles: profiles ?? this.profiles,
      currentProfile: currentProfile ?? this.currentProfile,
      partnerProfile: partnerProfile ?? this.partnerProfile,
      perspective: perspective ?? this.perspective,
      habits: habits ?? this.habits,
      habitLogs: habitLogs ?? this.habitLogs,
      workouts: workouts ?? this.workouts,
      journalEntries: journalEntries ?? this.journalEntries,
      notes: notes ?? this.notes,
      cycleEntries: cycleEntries ?? this.cycleEntries,
      mediaAssets: mediaAssets ?? this.mediaAssets,
    );
  }
}
