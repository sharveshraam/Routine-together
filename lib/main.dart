import 'package:duobloom_mobile/app/app.dart';
import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  await database.init();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const DuoBloomApp(),
    ),
  );
}
