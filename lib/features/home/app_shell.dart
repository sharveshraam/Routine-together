import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/navigation/app_page_route.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:duobloom_mobile/features/growth/growth_page.dart';
import 'package:duobloom_mobile/features/habits/habit_tracker_page.dart';
import 'package:duobloom_mobile/features/home/home_page.dart';
import 'package:duobloom_mobile/features/journal/journal_page.dart';
import 'package:duobloom_mobile/features/notes/notes_page.dart';
import 'package:duobloom_mobile/features/period/period_tracker_page.dart';
import 'package:duobloom_mobile/features/settings/settings_page.dart';
import 'package:duobloom_mobile/features/workouts/workout_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  void _openHabitPage() {
    Navigator.of(context).push(
      AppPageRoute(child: const HabitTrackerPage()),
    );
  }

  void _openWorkoutPage() {
    Navigator.of(context).push(
      AppPageRoute(child: const WorkoutTrackerPage()),
    );
  }

  void _openPeriodPage() {
    Navigator.of(context).push(
      AppPageRoute(child: const PeriodTrackerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        final isPartnerView = state.perspective == ViewPerspective.partner;
        final pages = [
          HomePage(
            onOpenHabits: _openHabitPage,
            onOpenWorkouts: _openWorkoutPage,
            onOpenJournal: () => setState(() => _index = 1),
            onOpenGrowth: () => setState(() => _index = 2),
            onOpenNotes: () => setState(() => _index = 3),
            onOpenPeriod: _openPeriodPage,
          ),
          const JournalPage(),
          const GrowthPage(),
          NotesPage(onOpenPeriod: _openPeriodPage),
          const SettingsPage(),
        ];

        return Scaffold(
          body: IndexedStack(index: _index, children: pages),
          extendBody: true,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PerspectiveToggle(
                isPartnerView: isPartnerView,
                onToggle: () {
                  ref.read(appControllerProvider.notifier).togglePerspective();
                },
              ),
              NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (value) {
                  setState(() => _index = value);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.hub_outlined),
                    label: 'Journal',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_rounded),
                    label: 'Growth',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.sticky_note_2_outlined),
                    label: 'Notes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text(error.toString())),
      ),
    );
  }
}
