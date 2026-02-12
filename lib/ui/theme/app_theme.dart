import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF090C12);
  static const Color surfaceColor = Color(0xFF151A25);
  static const Color incomeColor = Color(0xFF2ECC71);
  static const Color expenseColor = Color(0xFFE74C3C);
  static const Color futureColor = Color(0xFF3498DB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        surface: surfaceColor,
        background: backgroundColor,
        primary: futureColor,
        secondary: incomeColor,
        error: expenseColor,
      ),
    );
  }
}
