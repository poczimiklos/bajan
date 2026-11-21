import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/database_init.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  await initializeDateFormatting('hu_HU');
  Intl.defaultLocale = 'hu_HU';
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const PowerliftingApp(),
  ));
}
