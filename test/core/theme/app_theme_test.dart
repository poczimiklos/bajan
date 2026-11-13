import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:powerlifting_tracker/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('dark theme uses the requested Hextech colors and geometry', () {
    final theme = AppTheme.dark();

    expect(theme.scaffoldBackgroundColor, const Color(0xFF091428));
    expect(theme.colorScheme.surface, const Color(0xFF0A1428));
    expect(theme.colorScheme.primary, const Color(0xFF0AC8B9));
    expect(theme.colorScheme.secondary, const Color(0xFFC8AA6E));
    expect(theme.colorScheme.onSurface, const Color(0xFFF0E6D2));
    expect(theme.cardTheme.shape, isA<BeveledRectangleBorder>());
    expect(theme.filledButtonTheme.style?.shape?.resolve({}), isA<BeveledRectangleBorder>());
  });
}
