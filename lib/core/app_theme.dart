import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const _syne = 'Syne';
  static const _dmSans = 'DMSans';

  static TextTheme _buildTextTheme(ColorScheme cs) {
    final onSurface = cs.onSurface;
    final onSurfaceVariant = cs.onSurfaceVariant;
    final outline = cs.outline;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: onSurface,
        fontFamily: _syne,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        color: onSurface,
        fontFamily: _syne,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: onSurface,
        fontFamily: _syne,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: onSurface,
        fontFamily: _syne,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: onSurfaceVariant,
        fontFamily: _syne,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: onSurface,
        fontFamily: _syne,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: onSurfaceVariant,
        fontFamily: _syne,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        fontFamily: _dmSans,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        fontFamily: _dmSans,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: outline,
        fontFamily: _dmSans,
      ),
    );
  }

  static ThemeData darkTheme() {
    final cs = ColorScheme.dark(
      primary: AppColors.primary,
      surface: const Color(0xFF1E293B),
      surfaceContainerLow: const Color(0xFF0A0B12),
      surfaceContainer: const Color(0xFF334155),
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFFCBD5E1),
      outline: const Color(0xFF94A3B8),
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: cs,
      fontFamily: _dmSans,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(cs),
    );
  }

  static ThemeData lightTheme() {
    final cs = ColorScheme.light(
      primary: AppColors.primary,
      surface: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF3F4F6),
      surfaceContainer: const Color(0xFFE5E7EB),
      onSurface: const Color(0xFF1F2937),
      onSurfaceVariant: const Color(0xFF4B5563),
      outline: const Color(0xFF6B7280),
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: cs,
      fontFamily: _dmSans,
      dividerColor: Colors.black.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      ),
      textTheme: _buildTextTheme(cs),
    );
  }
}
