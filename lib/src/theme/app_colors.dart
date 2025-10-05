import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF212121);

  static const Color correct = Color(0xFF4CAF50); // green
  static const Color correctLight = Color(0xFFA5D6A7);
  static const Color wrong = Color(0xFFE53935);   // red
  static const Color wrongLight = Color(0xFFEF9A9A);

  // Grade category colors (exact values provided)
  static const Color sehrGut = Color(0xFF006D2C); // #006D2C
  static const Color gut = Color(0xFF66BD63);    // #66BD63
  static const Color befriedigend = Color(0xFFFEE08B); // #FEE08B
  static const Color ausreichend = Color(0xFFFD8D3C); // #FD8D3C
  static const Color mangelhaft = Color(0xFFD73027); // #D73027
  static const Color ungenuegend = Color(0xFFB10026); // #B10026

  // Dark mode
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFFE0E0E0);

  static const Color correctDark = Color(0xFF66BB6A);
  static const Color wrongDark = Color(0xFFEF5350);
}
