import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: const Color(0xFF1E293B),
        surfaceContainerLow: const Color(0xFF111827),
        surfaceContainer: const Color(0xFF334155),
        onSurface: const Color(0xFFFFFFFF),
        onSurfaceVariant: const Color(0xFFCBD5E1),
        outline: const Color(0xFF94A3B8),
        error: AppColors.error,
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        bodySmall: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF3F4F6),
        surfaceContainer: const Color(0xFFE5E7EB),
        onSurface: const Color(0xFF1F2937),
        onSurfaceVariant: const Color(0xFF4B5563),
        outline: const Color(0xFF6B7280),
        error: AppColors.error,
      ),
      dividerColor: Colors.black.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1F2937)),
        bodyMedium: TextStyle(color: Color(0xFF4B5563)),
        bodySmall: TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}
