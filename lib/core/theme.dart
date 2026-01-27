import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===============================================================
/// 🎨 Clinexa Brand Palette
/// ===============================================================
class AppColors {
  // =============================================================
  // 🌫️ Neutral (grises base para fondos, texto, bordes)
  // =============================================================
  static const neutral0 = Color(0xFF000000);
  static const neutral10 = Color(0xFF14171A);
  static const neutral20 = Color(0xFF1E2226);
  static const neutral30 = Color(0xFF2C3136);
  static const neutral40 = Color(0xFF454B51);
  static const neutral50 = Color(0xFF6B727A);
  static const neutral60 = Color(0xFF8E949B);
  static const neutral70 = Color(0xFFB0B5BA);
  static const neutral80 = Color(0xFFD3D6D9);
  static const neutral90 = Color(0xFFE6E8EA);
  static const neutral95 = Color(0xFFF3F4F5);
  static const neutral99 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFFFFFFF);

  // =============================================================
  // 💙 Primary (azul tecnológico – tomado del gradiente del logo)
  // =============================================================
  static const primary0 = Color(0xFF001633);
  static const primary10 = Color(0xFF003366);
  static const primary20 = Color(0xFF004C99);
  static const primary30 = Color(0xFF0066CC);
  static const primary40 = Color(0xFF007BFF); // principal Clinexa Blue
  static const primary50 = Color(0xFF339CFF);
  static const primary60 = Color(0xFF66B8FF);
  static const primary70 = Color(0xFF99D1FF);
  static const primary80 = Color(0xFFCCE8FF);
  static const primary90 = Color(0xFFE5F3FF);
  static const primary95 = Color(0xFFF0F9FF);
  static const primary99 = Color(0xFFFAFCFF);
  static const primary100 = Color(0xFFFFFFFF);

  // =============================================================
  // 💚 Secondary (turquesa-verde saludable del logo)
  // =============================================================
  static const secondary0 = Color(0xFF003731);
  static const secondary10 = Color(0xFF005A52);
  static const secondary20 = Color(0xFF007E72);
  static const secondary30 = Color(0xFF009E8C);
  static const secondary40 = Color(0xFF00BFA5); // principal Clinexa Green
  static const secondary50 = Color(0xFF2DD3BA);
  static const secondary60 = Color(0xFF5CE3CE);
  static const secondary70 = Color(0xFF8CF0DF);
  static const secondary80 = Color(0xFFBDF9EE);
  static const secondary90 = Color(0xFFDFFCF6);
  static const secondary95 = Color(0xFFEFFEF9);
  static const secondary99 = Color(0xFFF7FFFD);
  static const secondary100 = Color(0xFFFFFFFF);

  // =============================================================
  // ⚠️ Warning (amarillos suaves)
  // =============================================================
  static const warning0 = Color(0xFF7A4A00);
  static const warning10 = Color(0xFFA96B00);
  static const warning20 = Color(0xFFD98B00);
  static const warning30 = Color(0xFFFFA726);
  static const warning40 = Color(0xFFFFC04D);
  static const warning60 = Color(0xFFFFD47F);
  static const warning80 = Color(0xFFFFE8B3);
  static const warning99 = Color(0xFFFFFAF0);

  // =============================================================
  // ❌ Danger (rojos médicos – más suaves para interfaz clínica)
  // =============================================================
  static const danger0 = Color(0xFF5B0E0A);
  static const danger20 = Color(0xFFA81C18);
  static const danger40 = Color(0xFFD9362F);
  static const danger60 = Color(0xFFF15E58);
  static const danger80 = Color(0xFFF79D97);
  static const danger99 = Color(0xFFFFF2F2);

  // =============================================================
  // 🌈 Gradient sugerido (para botones o headers)
  // =============================================================
  static const gradientPrimary = LinearGradient(
    colors: [primary40, secondary40],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    //button config
    textTheme: GoogleFonts.urbanistTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.neutral20),
        bodyMedium: TextStyle(color: AppColors.neutral30),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral20,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary40,
        foregroundColor: AppColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary40,
        foregroundColor: AppColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary40,
        side: const BorderSide(color: AppColors.primary40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary40,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    //input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral95,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary50,
      secondary: AppColors.secondary50,
      surface: AppColors.neutral99,
      error: AppColors.danger40,
    ),
    scaffoldBackgroundColor: AppColors.neutral99,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.neutral99,
      foregroundColor: AppColors.neutral20,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    //button config
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary40,
        foregroundColor: AppColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary40,
        foregroundColor: AppColors.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary40,
        side: const BorderSide(color: AppColors.primary40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: GoogleFonts.urbanistTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.neutral20),
        bodyMedium: TextStyle(color: AppColors.neutral30),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral20,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary40,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    //input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral20,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary50,
      secondary: AppColors.secondary50,
      surface: AppColors.neutral10,
      error: AppColors.danger40,
    ),
    scaffoldBackgroundColor: AppColors.neutral10,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.neutral10,
      foregroundColor: AppColors.neutral95,
    ),
    // textTheme: const TextTheme(
    //   bodyLarge: TextStyle(color: AppColors.neutral95),
    //   bodyMedium: TextStyle(color: AppColors.neutral80),
    //   titleLarge: TextStyle(
    //     fontWeight: FontWeight.bold,
    //     color: AppColors.neutral99,
    //   ),
    // ),
  );
}
