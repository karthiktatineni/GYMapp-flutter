import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFB8860B);
  static const Color backgroundBlack = Color(0xFF0F0F0F);
  static const Color cardGrey = Color(0xFF1E1E1E);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.grey;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGold,
    scaffoldBackgroundColor: backgroundBlack,
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: textWhite,
      displayColor: textWhite,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: secondaryGold,
      surface: cardGrey,
      background: backgroundBlack,
    ),
    cardTheme: CardThemeData(
      color: cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: backgroundBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGold, width: 2),
      ),
    ),
  );
}
