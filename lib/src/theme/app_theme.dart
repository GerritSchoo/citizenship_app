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
  // Global radius tokens for consistent rounded corners across the app
  static const double radiusSmall = 12.0; // small controls, icon containers
  static const double radiusMedium = 20.0; // buttons, cards, chips, inputs
  static const double radiusLarge = 28.0; // sheets, dialogs, large containers

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
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
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
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: AppColors.primaryDark.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
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
