import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF6F5FF),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: Typography.blackMountainView,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF12131A),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF171A22),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: Typography.whiteMountainView,
    );
  }
}
