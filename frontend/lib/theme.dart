import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme (Cyber Indigo)
  static const bg          = Color(0xFF09090B);
  static const surface     = Color(0xFF18181B);
  static const surfaceHigh = Color(0xFF27272A);
  static const accent      = Color(0xFF8B5CF6);
  static const text        = Color(0xFFFAFAFA);
  static const textDim     = Color(0xFFA1A1AA);
  static const success     = Color(0xFF10B981);
  static const warn        = Color(0xFFF59E0B);
  static const danger      = Color(0xFFEF4444);

  // Light Theme Colors
  static const lightBg      = Color(0xFFF4F4F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText    = Color(0xFF18181B);
  static const lightTextDim = Color(0xFF52525B);
}

ThemeData buildTheme({bool isDark = true}) {
  final bgColor = isDark ? AppColors.bg : AppColors.lightBg;
  final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
  final textColor = isDark ? AppColors.text : AppColors.lightText;
  final textDimColor = isDark ? AppColors.textDim : AppColors.lightTextDim;
  final borderColor = isDark ? AppColors.surfaceHigh : const Color(0xFFE4E4E7);

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: bgColor,
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      iconTheme: IconThemeData(color: textColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: TextStyle(color: textDimColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return textDimColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return borderColor;
      }),
    ),
  );
}
