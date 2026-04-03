class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.partnerCode,
    this.connectedPartnerCode,
  });

  final String id;
  final String name;
  final String email;
  final String partnerCode;
  final String? connectedPartnerCode;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'partnerCode': partnerCode,
        'connectedPartnerCode': connectedPartnerCode,
      };
}

class Habit {
  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.streak,
    required this.isDoneToday,
  });

  final String id;
  final String userId;
  final String title;
  final int streak;
  final bool isDoneToday;
}

class WorkoutLog {
  WorkoutLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMinutes,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String type;
  final int durationMinutes;
  final DateTime timestamp;
}

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.content,
  });

  final String id;
  final String userId;
  final DateTime date;
  final String title;
  final String content;
}

class NoteItem {
  NoteItem({
    required this.id,
    required this.userId,
    required this.content,
    required this.forPartner,
  });

  final String id;
  final String userId;
  final String content;
  final bool forPartner;
}

class PeriodCycle {
  PeriodCycle({
    required this.id,
    required this.userId,
    required this.lastPeriodStart,
    required this.cycleLength,
  });

  final String id;
  final String userId;
  final DateTime lastPeriodStart;
  final int cycleLength;
}
