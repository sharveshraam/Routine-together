import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../widgets/animated_toggle.dart';
import '../widgets/avatar_header.dart';
import '../widgets/home_feature_card.dart';
import 'growth_screen.dart';
import 'habit_screen.dart';
import 'journal_screen.dart';
import 'notes_screen.dart';
import 'period_screen.dart';
import 'workout_screen.dart';
import 'auth_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Routine Together'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  AvatarHeader(userName: state.user.name, partnerName: state.partner.name),
                  const SizedBox(height: 14),
                  AnimatedViewToggle(partnerView: state.partnerView, onToggle: state.toggleView),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        HomeFeatureCard(
                          title: 'Habit Tracker',
                          subtitle: 'Daily checklist & streaks',
                          icon: Icons.task_alt,
                          onTap: () => _go(context, const HabitScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Workout Tracker',
                          subtitle: 'Weekly movement charts',
                          icon: Icons.fitness_center,
                          onTap: () => _go(context, const WorkoutScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Journal Timeline',
                          subtitle: 'Interactive relationship mind map',
                          icon: Icons.hub,
                          onTap: () => _go(context, const JournalScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Notes & Partner Notes',
                          subtitle: 'Personal and shared messages',
                          icon: Icons.sticky_note_2,
                          onTap: () => _go(context, const NotesScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Period Tracker',
                          subtitle: 'Cycle and ovulation prediction',
                          icon: Icons.calendar_month,
                          onTap: () => _go(context, const PeriodScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Authentication',
                          subtitle: 'Google, Email, Mobile OTP mock',
                          icon: Icons.login,
                          onTap: () => _go(context, const AuthScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Backup & Media Sync',
                          subtitle: 'Encrypted export/import + Google media',
                          icon: Icons.security,
                          onTap: () => _go(context, const SettingsScreen()),
                        ),
                        HomeFeatureCard(
                          title: 'Growth Progress',
                          subtitle: 'Days together & growth bars',
                          icon: Icons.insights,
                          onTap: () => _go(context, const GrowthScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
