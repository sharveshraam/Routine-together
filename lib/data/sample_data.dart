import '../models/entities.dart';

final sampleHabits = [
  Habit(id: 'h1', userId: 'u1', title: 'Morning Walk', streak: 9, isDoneToday: true),
  Habit(id: 'h2', userId: 'u1', title: 'Read 20 min', streak: 6, isDoneToday: false),
  Habit(id: 'h3', userId: 'u2', title: 'Meditation', streak: 14, isDoneToday: true),
];

final sampleWorkouts = [
  WorkoutLog(
    id: 'w1',
    userId: 'u1',
    type: 'Strength',
    durationMinutes: 45,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  WorkoutLog(
    id: 'w2',
    userId: 'u2',
    type: 'Cardio',
    durationMinutes: 30,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final sampleJournals = [
  JournalEntry(
    id: 'j1',
    userId: 'u1',
    date: DateTime.now().subtract(const Duration(days: 45)),
    title: 'First Hike Together',
    content: 'We completed our first mountain trail and promised weekly growth check-ins.',
  ),
  JournalEntry(
    id: 'j2',
    userId: 'u2',
    date: DateTime.now().subtract(const Duration(days: 8)),
    title: 'New Habit Streak',
    content: 'Both of us hit 7-day consistency on sleep and hydration.',
  ),
];
