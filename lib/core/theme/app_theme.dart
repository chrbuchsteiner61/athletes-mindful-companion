import 'package:flutter/material.dart';

class AppTheme {
  static const Color _sage = Color(0xFF7C9885);
  static const Color _sand = Color(0xFFF5F1E8);
  static const Color _ink = Color(0xFF2E3A2F);
  static const Color _muted = Color(0xFF6B7560);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _sage,
        secondary: _sand,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: _ink,
        onSecondary: _ink,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF8F3),
      textTheme: base.textTheme.apply(
        bodyColor: _ink,
        displayColor: _ink,
        fontFamily: 'Roboto',
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF8F3),
        elevation: 0,
        foregroundColor: _ink,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _sage,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _sand,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _sand,
        selectedColor: _sage.withOpacity(0.2),
        labelStyle: const TextStyle(color: _ink),
        side: BorderSide(color: _sage.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static const Color sage = _sage;
  static const Color sand = _sand;
  static const Color ink = _ink;
  static const Color muted = _muted;
}
