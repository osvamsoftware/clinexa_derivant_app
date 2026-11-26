// Clinexapp Design System — paleta y tipografía resueltas según el tema.
//
// Uso en pantallas:
//   final c = context.clx;        // colores del tema actual (claro u oscuro)
//   final t = context.clxText;    // escala tipográfica del sistema
//
// Este archivo es idéntico en las dos apps (derivante y receptor): si lo
// cambias en una, cópialo a la otra.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../clinexapp_tokens.dart';

/// Colores del sistema para el tema activo. Mismos nombres que tokens.json.
@immutable
class ClxPalette extends ThemeExtension<ClxPalette> {
  const ClxPalette({
    required this.brandBlue,
    required this.brandBlueHover,
    required this.brandBlueSoft,
    required this.onBrandBlueSoft,
    required this.brandTeal,
    required this.brandTealText,
    required this.brandTealSoft,
    required this.brandNavy,
    required this.accentViolet,
    required this.accentVioletSoft,
    required this.accentCoral,
    required this.accentAmber,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.onBrand,
    required this.onTeal,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.focusRing,
    required this.isDark,
  });

  final Color brandBlue;
  final Color brandBlueHover;
  final Color brandBlueSoft;

  /// Texto sobre [brandBlueSoft] (llega a 4.5:1).
  final Color onBrandBlueSoft;
  final Color brandTeal;
  final Color brandTealText;
  final Color brandTealSoft;
  final Color brandNavy;
  final Color accentViolet;
  final Color accentVioletSoft;
  final Color accentCoral;
  final Color accentAmber;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color onBrand;
  final Color onTeal;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color focusRing;
  final bool isDark;

  static const light = ClxPalette(
    brandBlue: ClxColors.brandBlue,
    brandBlueHover: ClxColors.brandBlueHover,
    brandBlueSoft: ClxColors.brandBlueSoft,
    onBrandBlueSoft: ClxColors.brandBlueHover,
    brandTeal: ClxColors.brandTeal,
    brandTealText: ClxColors.brandTealText,
    brandTealSoft: ClxColors.brandTealSoft,
    brandNavy: ClxColors.brandNavy,
    accentViolet: ClxColors.accentViolet,
    accentVioletSoft: ClxColors.accentVioletSoft,
    accentCoral: ClxColors.accentCoral,
    accentAmber: ClxColors.accentAmber,
    surface: ClxColors.surface,
    surfaceRaised: ClxColors.surfaceRaised,
    surfaceSunken: ClxColors.surfaceSunken,
    border: ClxColors.border,
    borderStrong: ClxColors.borderStrong,
    ink: ClxColors.ink,
    inkMuted: ClxColors.inkMuted,
    inkSubtle: ClxColors.inkSubtle,
    onBrand: ClxColors.onBrand,
    onTeal: ClxColors.onTeal,
    success: ClxColors.success,
    successSoft: ClxColors.successSoft,
    warning: ClxColors.warning,
    warningSoft: ClxColors.warningSoft,
    danger: ClxColors.danger,
    dangerSoft: ClxColors.dangerSoft,
    focusRing: ClxColors.focusRing,
    isDark: false,
  );

  static const dark = ClxPalette(
    brandBlue: ClxColorsDark.brandBlue,
    brandBlueHover: ClxColorsDark.brandBlueHover,
    brandBlueSoft: ClxColorsDark.brandBlueSoft,
    onBrandBlueSoft: ClxColorsDark.brandBlue,
    brandTeal: ClxColorsDark.brandTeal,
    brandTealText: ClxColorsDark.brandTealText,
    brandTealSoft: ClxColorsDark.brandTealSoft,
    brandNavy: ClxColorsDark.brandNavy,
    accentViolet: ClxColorsDark.accentViolet,
    accentVioletSoft: ClxColorsDark.accentVioletSoft,
    accentCoral: Color(0xFFFF8A66),
    accentAmber: Color(0xFFF5B94A),
    surface: ClxColorsDark.surface,
    surfaceRaised: ClxColorsDark.surfaceRaised,
    surfaceSunken: ClxColorsDark.surfaceSunken,
    border: ClxColorsDark.border,
    borderStrong: ClxColorsDark.borderStrong,
    ink: ClxColorsDark.ink,
    inkMuted: ClxColorsDark.inkMuted,
    inkSubtle: ClxColorsDark.inkSubtle,
    onBrand: ClxColorsDark.onBrand,
    onTeal: Color(0xFF06192B),
    success: ClxColorsDark.success,
    successSoft: Color(0xFF0E3523),
    warning: ClxColorsDark.warning,
    warningSoft: Color(0xFF3A2A08),
    danger: ClxColorsDark.danger,
    dangerSoft: Color(0xFF3D1019),
    focusRing: ClxColorsDark.focusRing,
    isDark: true,
  );

  /// Degradado de marca (teal → azul). Solo en piezas de marca.
  LinearGradient get brandGradient => LinearGradient(
        colors: [brandTeal, brandBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Sombra de tarjeta. En oscuro las sombras no se ven: se usa el borde.
  List<BoxShadow> get shadowCard => isDark ? const [] : ClxShadow.card;
  List<BoxShadow> get shadowFloat => isDark ? const [] : ClxShadow.float;

  @override
  ClxPalette copyWith() => this;

  @override
  ClxPalette lerp(ThemeExtension<ClxPalette>? other, double t) {
    if (other is! ClxPalette) return this;
    return t < 0.5 ? this : other;
  }
}

/// Escala tipográfica del sistema (Geist + Source Code Pro).
class ClxTextStyles {
  ClxTextStyles(this.c);
  final ClxPalette c;

  /// Una vez por pantalla, como mucho.
  TextStyle get display => GoogleFonts.geist(fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, color: c.ink);

  /// Título de pantalla.
  TextStyle get h1 => GoogleFonts.geist(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: c.ink);

  /// Título de sección.
  TextStyle get h2 => GoogleFonts.geist(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: c.ink);

  /// Título de tarjeta.
  TextStyle get h3 => GoogleFonts.geist(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, color: c.ink);
  TextStyle get body => GoogleFonts.geist(fontSize: 15, height: 22 / 15, color: c.ink);
  TextStyle get bodyStrong => GoogleFonts.geist(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600, color: c.ink);
  TextStyle get bodyMuted => GoogleFonts.geist(fontSize: 15, height: 22 / 15, color: c.inkMuted);
  TextStyle get bodySm => GoogleFonts.geist(fontSize: 13, height: 18 / 13, color: c.inkMuted);
  TextStyle get bodySmStrong => GoogleFonts.geist(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w600, color: c.ink);

  /// Rótulo en MAYÚSCULAS con tracking (pasa el texto ya en mayúsculas).
  TextStyle get label => GoogleFonts.geist(fontSize: 11.5, height: 16 / 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: c.inkSubtle);

  /// Montos, códigos de protocolo, IDs y fechas.
  TextStyle get data => GoogleFonts.sourceCodePro(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: c.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  TextStyle get dataLg => GoogleFonts.sourceCodePro(
        fontSize: 26,
        height: 32 / 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: c.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  TextStyle get link => GoogleFonts.geist(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600, color: c.brandBlue);
}

extension ClxContext on BuildContext {
  /// Colores del sistema para el tema activo.
  ClxPalette get clx => Theme.of(this).extension<ClxPalette>() ?? ClxPalette.light;

  /// Estilos de texto del sistema para el tema activo.
  ClxTextStyles get clxText => ClxTextStyles(clx);
}
