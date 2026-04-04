import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/features/auth/onboarding_page.dart';
import 'package:duobloom_mobile/features/home/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';

class DuoBloomApp extends StatelessWidget {
  const DuoBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DuoBloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _LaunchGate(),
    );
  }
}

class _LaunchGate extends ConsumerWidget {
  const _LaunchGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);

    return appState.when(
      data: (state) {
        if (!state.isOnboarded) {
          return const OnboardingPage();
        }
        return const AppShell();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'DuoBloom could not start.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
