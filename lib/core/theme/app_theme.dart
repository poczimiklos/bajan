import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF091428);
  static const card = Color(0xFF0A1428);
  static const card2 = Color(0xFF13233D);
  static const accent = Color(0xFF0AC8B9);
  static const gold = Color(0xFFC8AA6E);
  static const text = Color(0xFFF0E6D2);
  static const muted = Color(0xFF91A2BA);
  static const danger = Color(0xFFFF6B7A);
  static const warn = Color(0xFFE7B85B);
}

class AppTheme {
  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppColors.bg,
        card: AppColors.card,
        field: AppColors.card2,
        primary: AppColors.accent,
        text: AppColors.text,
        muted: AppColors.muted,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: const Color(0xFFECF2F7),
        card: const Color(0xFFF7FAFC),
        field: const Color(0xFFE1EAF1),
        primary: const Color(0xFF087F7A),
        text: const Color(0xFF10213A),
        muted: const Color(0xFF52657D),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color field,
    required Color primary,
    required Color text,
    required Color muted,
  }) {
    final dark = brightness == Brightness.dark;
    final onPrimary = dark ? AppColors.bg : Colors.white;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: card,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.gold,
      onSecondary: dark ? AppColors.bg : Colors.white,
      surface: card,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceContainerHighest: field,
      error: AppColors.danger,
      onError: text,
      outline: AppColors.gold.withValues(alpha: 0.62),
      outlineVariant: AppColors.gold.withValues(alpha: 0.27),
    );
    final base = ThemeData(brightness: brightness, useMaterial3: true, colorScheme: scheme);
    final bodyText = GoogleFonts.rajdhaniTextTheme(base.textTheme).apply(bodyColor: text, displayColor: text);
    final textTheme = GoogleFonts.orbitronTextTheme(bodyText).copyWith(
      bodyLarge: bodyText.bodyLarge,
      bodyMedium: bodyText.bodyMedium,
      bodySmall: bodyText.bodySmall,
      labelSmall: bodyText.labelSmall,
      labelMedium: bodyText.labelMedium,
      labelLarge: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w700, color: text),
      titleSmall: bodyText.titleSmall,
      titleMedium: GoogleFonts.rajdhani(fontSize: 17, fontWeight: FontWeight.w700, color: text),
      titleLarge: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700, color: text),
      headlineSmall: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: text),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      cardColor: card,
      canvasColor: bg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      textSelectionTheme: TextSelectionThemeData(cursorColor: primary, selectionColor: primary.withValues(alpha: 0.3)),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700, color: text),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bg,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.12),
        shape: BeveledRectangleBorder(
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: primary.withValues(alpha: 0.18),
        indicatorShape: const BeveledRectangleBorder(),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w600, color: muted),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? primary : muted),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        indicatorColor: primary.withValues(alpha: 0.18),
        indicatorShape: const BeveledRectangleBorder(),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: GoogleFonts.rajdhani(color: text, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: GoogleFonts.rajdhani(color: muted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        labelStyle: GoogleFonts.rajdhani(color: muted, fontSize: 14, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 3,
          shadowColor: primary.withValues(alpha: 0.35),
          animationDuration: const Duration(milliseconds: 180),
          textStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.w800, fontSize: 16),
          shape: const BeveledRectangleBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: text,
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.65)),
          animationDuration: const Duration(milliseconds: 180),
          textStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
          shape: const BeveledRectangleBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
          shape: const BeveledRectangleBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: primary, shape: const BeveledRectangleBorder()),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: field,
        selectedColor: primary.withValues(alpha: 0.2),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.32)),
        labelStyle: GoogleFonts.rajdhani(color: text, fontWeight: FontWeight.w700),
        shape: const BeveledRectangleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: BeveledRectangleBorder(side: BorderSide(color: AppColors.gold.withValues(alpha: 0.65))),
        titleTextStyle: GoogleFonts.orbitron(color: text, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        shape: BeveledRectangleBorder(side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4))),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: BeveledRectangleBorder(side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: field,
        contentTextStyle: GoogleFonts.rajdhani(color: text, fontWeight: FontWeight.w600),
        shape: const BeveledRectangleBorder(),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: const BeveledRectangleBorder(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: field,
        circularTrackColor: field,
      ),
      dividerColor: AppColors.gold.withValues(alpha: 0.16),
      splashColor: primary.withValues(alpha: 0.12),
      highlightColor: primary.withValues(alpha: 0.07),
      bottomAppBarTheme: BottomAppBarThemeData(color: card),
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
