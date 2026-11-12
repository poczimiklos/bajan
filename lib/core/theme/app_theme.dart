import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D0F12);
  static const card = Color(0xFF181B20);
  static const card2 = Color(0xFF21252C);
  static const accent = Color(0xFFC6FF3D);
  static const muted = Color(0xFF8B93A1);
  static const danger = Color(0xFFFF5C5C);
  static const warn = Color(0xFFFFB84D);
}

class AppTheme {
  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppColors.bg,
        card: AppColors.card,
        primary: AppColors.accent,
        onPrimary: Colors.black,
        text: Colors.white,
        muted: AppColors.muted,
        field: AppColors.card2,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: const Color(0xFFF3F4F6),
        card: Colors.white,
        primary: const Color(0xFF5E8C00),
        onPrimary: Colors.white,
        text: const Color(0xFF111418),
        muted: const Color(0xFF6B7280),
        field: const Color(0xFFE8EAED),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color primary,
    required Color onPrimary,
    required Color text,
    required Color muted,
    required Color field,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      surface: card,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceContainerHighest: field,
      outline: muted.withValues(alpha: 0.4),
    );
    final base = ThemeData(brightness: brightness, useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      cardColor: card,
      canvasColor: bg,
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, color: muted)),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? primary : muted),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: text,
          side: BorderSide(color: muted.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: field,
        selectedColor: primary.withValues(alpha: 0.25),
        side: BorderSide.none,
        labelStyle: TextStyle(color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: muted.withValues(alpha: 0.15),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: card),
    );
  }
}

extension ThemeCtx on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  Color get accent => cs.primary;
  Color get muted => cs.onSurfaceVariant;
  Color get cardBg => Theme.of(this).cardColor;
  Color get fieldBg => cs.surfaceContainerHighest;
}
