import 'package:flutter/material.dart';
import 'palette.dart';

final appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.cremaSuave,
  primaryColor: AppColors.coralSuave,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: generateMaterialColor(AppColors.coralSuave),
    accentColor: AppColors.melocotonPastel,
    backgroundColor: AppColors.cremaSuave,
  ).copyWith(
    secondary: AppColors.melocotonPastel,
    background: AppColors.cremaSuave,
    error: Colors.redAccent,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.marronClaro),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.coralSuave,
      foregroundColor: Colors.white,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    fillColor: Colors.white,
    filled: true,
  ),
);

// Extra: función para generar MaterialColor a partir de un Color plano
MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, <int, Color>{
    50: color.withOpacity(.1),
    100: color.withOpacity(.2),
    200: color.withOpacity(.3),
    300: color.withOpacity(.4),
    400: color.withOpacity(.5),
    500: color.withOpacity(.6),
    600: color.withOpacity(.7),
    700: color.withOpacity(.8),
    800: color.withOpacity(.9),
    900: color.withOpacity(1),
  });
}
