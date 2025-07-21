import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Color(0xFFF7F7F8),
      surface: Colors.white,
      onSurface: Colors.black,
      tertiary: Color.fromARGB(255, 202, 202, 202),
      onTertiary: Color.fromARGB(255, 87, 87, 87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF131314),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Color(0xFF1E1F20),
      surface: Color(0xFF131314),
      onSurface: Colors.white,
      tertiary: Color.fromARGB(255, 56, 58, 59),
      onTertiary: Color.fromARGB(255, 202, 202, 202),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131314),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
    ),
  );
}