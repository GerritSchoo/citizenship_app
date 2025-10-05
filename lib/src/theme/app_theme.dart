import 'package:flutter/material.dart';
import 'app_colors.dart';

class GradeColors extends ThemeExtension<GradeColors> {
  final Color sehrGut;
  final Color gut;
  final Color befriedigend;
  final Color ausreichend;
  final Color mangelhaft;
  final Color ungenuegend;

  const GradeColors({
    required this.sehrGut,
    required this.gut,
    required this.befriedigend,
    required this.ausreichend,
    required this.mangelhaft,
    required this.ungenuegend,
  });

  @override
  ThemeExtension<GradeColors> copyWith({
    Color? sehrGut,
    Color? gut,
    Color? befriedigend,
    Color? ausreichend,
    Color? mangelhaft,
    Color? ungenuegend,
  }) {
    return GradeColors(
      sehrGut: sehrGut ?? this.sehrGut,
      gut: gut ?? this.gut,
      befriedigend: befriedigend ?? this.befriedigend,
      ausreichend: ausreichend ?? this.ausreichend,
      mangelhaft: mangelhaft ?? this.mangelhaft,
      ungenuegend: ungenuegend ?? this.ungenuegend,
    );
  }

  @override
  ThemeExtension<GradeColors> lerp(ThemeExtension<GradeColors>? other, double t) {
    if (other is! GradeColors) return this;
    return GradeColors(
      sehrGut: Color.lerp(sehrGut, other.sehrGut, t) ?? sehrGut,
      gut: Color.lerp(gut, other.gut, t) ?? gut,
      befriedigend: Color.lerp(befriedigend, other.befriedigend, t) ?? befriedigend,
      ausreichend: Color.lerp(ausreichend, other.ausreichend, t) ?? ausreichend,
      mangelhaft: Color.lerp(mangelhaft, other.mangelhaft, t) ?? mangelhaft,
      ungenuegend: Color.lerp(ungenuegend, other.ungenuegend, t) ?? ungenuegend,
    );
  }
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    extensions: <ThemeExtension<dynamic>>[
      const GradeColors(
        sehrGut: AppColors.sehrGut,
        gut: AppColors.gut,
        befriedigend: AppColors.befriedigend,
        ausreichend: AppColors.ausreichend,
        mangelhaft: AppColors.mangelhaft,
        ungenuegend: AppColors.ungenuegend,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    extensions: <ThemeExtension<dynamic>>[
      const GradeColors(
        sehrGut: AppColors.sehrGut,
        gut: AppColors.gut,
        befriedigend: AppColors.befriedigend,
        ausreichend: AppColors.ausreichend,
        mangelhaft: AppColors.mangelhaft,
        ungenuegend: AppColors.ungenuegend,
      ),
    ],
  );
}
