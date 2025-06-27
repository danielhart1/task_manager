import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from your Figma
  static const Color primary = Color(0xFF3E64FF);
  static const Color secondary = Color(0xFF7B61FF);
  static const Color darkBackground = Color(0xFF0F0F1C);
  static const Color darkCard = Color(0xFF1C1C2B);

  static ThemeData light() {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      primaryColor: secondary,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
      ),
    );
  }
}