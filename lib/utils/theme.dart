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
        tertiary: Color.fromARGB(255, 244, 244, 244),
        onTertiary: Color.fromARGB(255, 87, 87, 87),
        tertiaryFixedDim: Color.fromARGB(255, 222, 222, 222),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color.fromARGB(255, 216, 48, 48),
        contentTextStyle: TextStyle(
          color: Colors.white,
        ),
        dismissDirection: DismissDirection.horizontal,
        elevation: 10,
      ),
      textTheme: TextTheme(
          bodyLarge: TextStyle(
        fontSize: 16,
      )));

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF131314),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Color(0xFF1E1F20),
      surface: Color(0xFF131314),
      onSurface: Colors.white,
      tertiary: Color.fromARGB(255, 48, 48, 48),
      tertiaryFixedDim: Color.fromARGB(255, 54, 54, 54),
      onTertiary: Color.fromARGB(255, 202, 202, 202),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color.fromARGB(255, 216, 48, 48),
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
      dismissDirection: DismissDirection.horizontal,
      elevation: 10,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131314),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
    ),
  );
}
