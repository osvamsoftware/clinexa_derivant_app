import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'clinexapp_tokens.dart';

export 'clinexapp_tokens.dart';

/// ===============================================================
/// Paleta de Clinexapp
/// ===============================================================
/// Los nombres se conservan para no tocar cada pantalla, pero los valores
/// salen del Clinexapp Design System (ver clinexapp_tokens.dart). Para código
/// nuevo usa ClxColors directamente.
class AppColors {
  // Neutros con tinte azul marino
  static const neutral0 = Color(0xFF000000);
  static const neutral10 = Color(0xFF0A1A2B); // fondo oscuro
  static const neutral20 = ClxColors.ink; // texto principal
  static const neutral30 = Color(0xFF2A3D55);
  static const neutral40 = ClxColors.inkMuted; // texto secundario
  static const neutral50 = ClxColors.inkSubtle; // metadatos, placeholders
  static const neutral60 = ClxColors.borderStrong; // bordes de controles, íconos apagados
  static const neutral70 = Color(0xFFA7B6C8);
  static const neutral80 = Color(0xFFC9D3DF);
  static const neutral90 = ClxColors.border; // divisores
  static const neutral95 = ClxColors.surfaceSunken;
  static const neutral99 = ClxColors.surface; // fondo de pantalla
  static const neutral100 = Color(0xFFFFFFFF);

  // Azul Clinexapp (primary40 = el azul del logo)
  static const primary0 = Color(0xFF021A33);
  static const primary10 = Color(0xFF03305C);
  static const primary20 = Color(0xFF04477F);
  static const primary30 = ClxColors.brandBlueHover;
  static const primary40 = ClxColors.brandBlue;
  static const primary50 = Color(0xFF2B8DDB);
  static const primary60 = Color(0xFF4DA3F0);
  static const primary70 = Color(0xFF7BBCF5);
  static const primary80 = Color(0xFFA9D3F8);
  static const primary90 = Color(0xFFD2E7FB);
  static const primary95 = ClxColors.brandBlueSoft;
  static const primary99 = Color(0xFFF5FAFE);
  static const primary100 = Color(0xFFFFFFFF);

  // Verde agua (secondary40 es apto para texto; el del logo es secondary60)
  static const secondary0 = Color(0xFF00221D);
  static const secondary10 = Color(0xFF003A32);
  static const secondary20 = Color(0xFF005247);
  static const secondary30 = Color(0xFF006B5D);
  static const secondary40 = ClxColors.brandTealText;
  static const secondary50 = Color(0xFF00A693);
  static const secondary60 = ClxColors.brandTeal;
  static const secondary70 = Color(0xFF2FD9C2);
  static const secondary80 = Color(0xFF8CEBDD);
  static const secondary90 = Color(0xFFC4F4EC);
  static const secondary95 = ClxColors.brandTealSoft;
  static const secondary99 = Color(0xFFF3FCFA);
  static const secondary100 = Color(0xFFFFFFFF);

  // Advertencia
  static const warning0 = Color(0xFF5C3800);
  static const warning10 = Color(0xFF6F4400);
  static const warning20 = ClxColors.warning; // texto
  static const warning30 = Color(0xFFC27A00);
  static const warning40 = ClxColors.accentAmber;
  static const warning60 = Color(0xFFF8C46A);
  static const warning80 = Color(0xFFFDE3B0);
  static const warning99 = ClxColors.warningSoft;

  // Error
  static const danger0 = Color(0xFF5B0A1A);
  static const danger20 = Color(0xFFA3122F);
  static const danger40 = ClxColors.danger;
  static const danger60 = Color(0xFFFF6B81);
  static const danger80 = Color(0xFFF9B4C0);
  static const danger99 = ClxColors.dangerSoft;

  // Éxito
  static const success = ClxColors.success;
  static const successSoft = ClxColors.successSoft;

  /// Degradado de marca del logo.
  static const gradientPrimary = ClxColors.brandGradient;
}

class AppTheme {
  static ThemeData lightTheme = _build(Brightness.light);
  static ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final blue = dark ? ClxColorsDark.brandBlue : ClxColors.brandBlue;
    final onBlue = dark ? ClxColorsDark.onBrand : ClxColors.onBrand;
    final surface = dark ? ClxColorsDark.surface : ClxColors.surface;
    final raised = dark ? ClxColorsDark.surfaceRaised : ClxColors.surfaceRaised;
    final sunken = dark ? ClxColorsDark.surfaceSunken : ClxColors.surfaceSunken;
    final ink = dark ? ClxColorsDark.ink : ClxColors.ink;
    final muted = dark ? ClxColorsDark.inkMuted : ClxColors.inkMuted;
    final subtle = dark ? ClxColorsDark.inkSubtle : ClxColors.inkSubtle;
    final border = dark ? ClxColorsDark.border : ClxColors.border;
    final borderStrong = dark ? ClxColorsDark.borderStrong : ClxColors.borderStrong;
    final danger = dark ? ClxColorsDark.danger : ClxColors.danger;
    final focus = dark ? ClxColorsDark.focusRing : ClxColors.focusRing;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: blue,
      onPrimary: onBlue,
      primaryContainer: dark ? ClxColorsDark.brandBlueSoft : ClxColors.brandBlueSoft,
      onPrimaryContainer: dark ? ClxColorsDark.brandBlue : ClxColors.brandBlueHover,
      secondary: dark ? ClxColorsDark.brandTeal : ClxColors.brandTeal,
      onSecondary: ClxColors.onTeal,
      secondaryContainer: dark ? ClxColorsDark.brandTealSoft : ClxColors.brandTealSoft,
      onSecondaryContainer: ink,
      tertiary: dark ? ClxColorsDark.accentViolet : ClxColors.accentViolet,
      onTertiary: dark ? ClxColorsDark.onBrand : ClxColors.onBrand,
      error: danger,
      onError: dark ? ClxColorsDark.onBrand : ClxColors.onBrand,
      surface: raised,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerLowest: raised,
      surfaceContainerLow: raised,
      surfaceContainer: raised,
      surfaceContainerHigh: sunken,
      surfaceContainerHighest: sunken,
      outline: borderStrong,
      outlineVariant: border,
    );

    final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme);
    final text = GoogleFonts.geistTextTheme(base.textTheme).apply(bodyColor: ink, displayColor: ink).copyWith(
          headlineMedium: GoogleFonts.geist(fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: ink),
          headlineSmall: GoogleFonts.geist(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, color: ink),
          titleLarge: GoogleFonts.geist(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w600, color: ink),
          titleMedium: GoogleFonts.geist(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w600, color: ink),
          bodyLarge: GoogleFonts.geist(fontSize: 16, height: 24 / 16, color: ink),
          bodyMedium: GoogleFonts.geist(fontSize: 15, height: 22 / 15, color: ink),
          bodySmall: GoogleFonts.geist(fontSize: 13, height: 20 / 13, color: muted),
          labelLarge: GoogleFonts.geist(fontSize: 15, fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.7, color: muted),
        );

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.md));
    const controlPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final labelStyle = GoogleFonts.geist(fontSize: 16, fontWeight: FontWeight.w600);

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClxRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.geist(fontSize: 17, fontWeight: FontWeight.w600, color: ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: onBlue,
          elevation: 0,
          shape: controlShape,
          padding: controlPadding,
          textStyle: labelStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: onBlue,
          shape: controlShape,
          padding: controlPadding,
          textStyle: labelStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: borderStrong),
          shape: controlShape,
          padding: controlPadding,
          textStyle: labelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: blue, shape: controlShape, textStyle: labelStyle),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.geist(color: subtle),
        labelStyle: GoogleFonts.geist(color: muted),
        floatingLabelStyle: GoogleFonts.geist(color: focus, fontWeight: FontWeight.w600),
        border: outline(borderStrong),
        enabledBorder: outline(borderStrong),
        focusedBorder: outline(focus, 2),
        errorBorder: outline(danger),
        focusedErrorBorder: outline(danger, 2),
        errorStyle: GoogleFonts.geist(color: danger, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: raised,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.lg), side: BorderSide(color: border)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.xl)),
        titleTextStyle: GoogleFonts.geist(fontSize: 20, fontWeight: FontWeight.w600, color: ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: raised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ClxRadius.xl))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? ClxColorsDark.surfaceRaised : ClxColors.ink,
        contentTextStyle: GoogleFonts.geist(color: dark ? ClxColorsDark.ink : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.md)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sunken,
        selectedColor: scheme.primaryContainer,
        labelStyle: GoogleFonts.geist(fontSize: 13, fontWeight: FontWeight.w600, color: ink),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.pill)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: raised,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: raised,
        selectedItemColor: blue,
        unselectedItemColor: subtle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: blue,
        foregroundColor: onBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.lg)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: blue),
      checkboxTheme: CheckboxThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.sm))),
    );
  }
}
