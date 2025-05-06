import 'package:flutter/material.dart';

enum AppThemeOption { claroVerde, claroAzul, oscuro }

class AppThemes {
  static final ThemeData normalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF144D37),
    scaffoldBackgroundColor: const Color(0xFF144D37),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF144D37),
      primary: const Color(0xFF144D37),
      secondary: Colors.white,
      tertiary: Colors.yellow,
      surface: Color(0xFF232525),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF144D37),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    primaryColorLight: Colors.yellow.shade200,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF232525),
    scaffoldBackgroundColor: Color(0xFF232525),
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      secondary: Color(0xFF3B3C3C),
      tertiary: Colors.lightBlue,
      surface: Color(0xFF232525),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF232525),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    primaryColorLight: Colors.blue,
  );

  static final ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E3A8A),
    scaffoldBackgroundColor: const Color(0xFF1E3A8A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A),
      primary: const Color(0xFF1E3A8A),
      secondary: Colors.white,
      tertiary: Colors.yellow,
      surface: const Color(0xFF2B2E3B),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E3A8A),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    primaryColorLight: Colors.lightBlueAccent,
  );

  static ThemeData getTheme(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.claroAzul:
        return blueTheme;
      case AppThemeOption.oscuro:
        return darkTheme;
      case AppThemeOption.claroVerde:
        return normalTheme;
    }
  }
}
