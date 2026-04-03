import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class RoutineTogetherApp extends StatelessWidget {
  const RoutineTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF7E57C2),
      scaffoldBackgroundColor: const Color(0xFF111218),
      cardTheme: CardTheme(
        color: const Color(0xFF1A1C24).withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Routine Together',
      theme: theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
