import 'package:flutter/material.dart';

class AppTheme {
  // App colors
  static const Color darkBackground = Color(0xFF1A222F);
  static const Color darkSurface = Color(0xFF273546);
  static const Color accentYellow = Color(0xFFFFC940);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF8D9CAD);
  
  // The dark theme for the app
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackground,
    primaryColor: accentYellow,
    colorScheme: ColorScheme.dark(
      primary: accentYellow,
      secondary: accentYellow,
      surface: darkSurface,
      background: darkBackground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(
        color: textLight, 
        fontSize: 20, 
        fontWeight: FontWeight.w600
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textLight,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textLight,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textGrey,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentYellow, width: 1),
      ),
      hintStyle: TextStyle(color: textGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentYellow,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    iconTheme: IconThemeData(
      color: textLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: accentYellow,
      unselectedItemColor: textGrey,
    ),
  );
}