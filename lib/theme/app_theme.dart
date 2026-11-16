import 'package:flutter/material.dart';

/// Globio brand palette — taken 1:1 from the CSS tokens on globio.ai
/// (`:root { --brand, --primary, --secondary, ... }`), converted HSL › hex.
class GlobioColors {
  GlobioColors._();

  /// --brand: hsl(238 67% 29%) — navbar, dark sections.
  static const brand = Color(0xFF181C7B);

  /// --primary: hsl(238 69% 44%) — buttons, links, eyebrow labels.
  static const primary = Color(0xFF2328BE);

  /// Hero gradient end used on globio.ai: hsl(238 80% 36%).
  static const heroEnd = Color(0xFF1217A5);

  /// --accent: hsl(237 72% 62%).
  static const accent = Color(0xFF585FE4);

  /// --secondary (gold): hsl(42 100% 60%) — "Sign up", highlights.
  static const secondary = Color(0xFFFFC233);

  /// Gold gradient end: hsl(42 100% 75%).
  static const goldLight = Color(0xFFFFD980);

  /// --foreground: hsl(215 76% 12%) — text on white.
  static const foreground = Color(0xFF071B36);

  /// --muted-foreground: hsl(215 20% 50%).
  static const mutedForeground = Color(0xFF667B99);

  /// --muted: hsl(225 35% 96%).
  static const muted = Color(0xFFF1F3F8);

  /// --border / --input: hsl(220 20% 90%).
  static const border = Color(0xFFE0E4EB);

  /// --background / --card.
  static const background = Color(0xFFFFFFFF);

  /// --destructive: hsl(0 84% 60%).
  static const destructive = Color(0xFFEF4343);

  /// Light red background used on globio.ai for error states (#FFE2E2).
  static const destructiveSoft = Color(0xFFFFE2E2);

  /// Success: globio.ai's CSS uses the emerald family (#ECFDF5, #D0FAE5,
  /// #A4F4CF). Emerald-600 is used for readable text/icons on white.
  static const success = Color(0xFF009966);
  static const successSoft = Color(0xFFECFDF5);

  /// Soft gold background (#FEF3C6, used on globio.ai for highlights).
  static const secondarySoft = Color(0xFFFEF3C6);

  /// Hero background: linear-gradient(150deg, brand 0%, primary 55%, heroEnd 100%).
  static const heroGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [brand, primary, heroEnd],
    stops: [0, 0.55, 1],
  );

  /// linear-gradient(135deg, primary 0%, brand 100%) — CTA bands.
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, brand],
  );

  /// linear-gradient(90deg, secondary, goldLight) — gold text highlight.
  static const goldGradient = LinearGradient(colors: [secondary, goldLight]);
}

class GlobioTheme {
  GlobioTheme._();

  /// --radius: .75rem = 12px.
  static const radius = 12.0;
  static const fontFamily = 'Poppins';

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: GlobioColors.primary,
      onPrimary: Colors.white,
      secondary: GlobioColors.secondary,
      onSecondary: GlobioColors.foreground,
      tertiary: GlobioColors.accent,
      onTertiary: Colors.white,
      error: GlobioColors.destructive,
      onError: Colors.white,
      surface: GlobioColors.background,
      onSurface: GlobioColors.foreground,
      outline: GlobioColors.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: GlobioColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: GlobioColors.foreground,
        displayColor: GlobioColors.foreground,
        fontFamily: fontFamily,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: GlobioColors.mutedForeground, fontSize: 14),
        labelStyle: const TextStyle(color: GlobioColors.mutedForeground, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius - 4),
          borderSide: const BorderSide(color: GlobioColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius - 4),
          borderSide: const BorderSide(color: GlobioColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius - 4),
          borderSide: const BorderSide(color: GlobioColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius - 4),
          borderSide: const BorderSide(color: GlobioColors.destructive),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: GlobioColors.brand,
        contentTextStyle: TextStyle(fontFamily: fontFamily, color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
