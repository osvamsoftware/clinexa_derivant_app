// Clinexapp Design System — tokens para Flutter.
//
// Fuente única: design-system/tokens.json (el mismo sistema que usa el panel
// de administración). Si cambias un valor, cámbialo allí y aquí, con el mismo
// nombre en camelCase.
import 'package:flutter/material.dart';

/// Colores del sistema en tema claro.
class ClxColors {
  ClxColors._();

  // Marca (del logo)
  static const brandBlue = Color(0xFF0875C9);
  static const brandBlueHover = Color(0xFF0661A8);
  static const brandBlueSoft = Color(0xFFE7F1FB);
  static const brandTeal = Color(0xFF00C4AC); // solo relleno; encima va onTeal
  static const brandTealText = Color(0xFF00806F);
  static const brandTealSoft = Color(0xFFE0F7F3);
  static const brandNavy = Color(0xFF1B426E);

  // Complementarios
  static const accentViolet = Color(0xFF5B4FF0); // reservado para la IA
  static const accentVioletSoft = Color(0xFFEEEDFE);
  static const accentCoral = Color(0xFFF2643F); // solo relleno
  static const accentAmber = Color(0xFFF5A524); // solo relleno

  // Superficies y texto
  static const surface = Color(0xFFF6F9FC);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFEDF2F7);
  static const border = Color(0xFFE3E8EE);
  static const borderStrong = Color(0xFF8796AB);
  static const ink = Color(0xFF0B2239);
  static const inkMuted = Color(0xFF4A5B72);
  static const inkSubtle = Color(0xFF5C6C82);
  static const onBrand = Color(0xFFFFFFFF);
  static const onTeal = Color(0xFF0B2239);

  // Estados (siempre con palabra o ícono, nunca solo color)
  static const success = Color(0xFF176E41);
  static const successSoft = Color(0xFFE3F5EA);
  static const warning = Color(0xFF8A5300);
  static const warningSoft = Color(0xFFFDF3DC);
  static const danger = Color(0xFFD0193C);
  static const dangerSoft = Color(0xFFFDE8EC);
  static const focusRing = Color(0xFF0875C9);

  /// Degradado de marca (teal → azul, como el logo). Solo en piezas de marca.
  static const brandGradient = LinearGradient(
    colors: [brandTeal, brandBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Colores del sistema en tema oscuro (mismos nombres).
class ClxColorsDark {
  ClxColorsDark._();

  static const brandBlue = Color(0xFF4DA3F0);
  static const brandBlueHover = Color(0xFF7BBCF5);
  static const brandBlueSoft = Color(0xFF0F3352);
  static const brandTeal = Color(0xFF2FD9C2);
  static const brandTealText = Color(0xFF2FD9C2);
  static const brandTealSoft = Color(0xFF0C3A38);
  static const brandNavy = Color(0xFF9FC3EA);
  static const accentViolet = Color(0xFFA39BFF);
  static const accentVioletSoft = Color(0xFF26224F);
  static const surface = Color(0xFF0A1A2B);
  static const surfaceRaised = Color(0xFF10243A);
  static const surfaceSunken = Color(0xFF07131F);
  static const border = Color(0xFF22405E);
  static const borderStrong = Color(0xFF5D7896);
  static const ink = Color(0xFFEAF1F8);
  static const inkMuted = Color(0xFFA7B6C8);
  static const inkSubtle = Color(0xFF8597AD);
  static const onBrand = Color(0xFF06192B);
  static const success = Color(0xFF4CC98A);
  static const warning = Color(0xFFF5B94A);
  static const danger = Color(0xFFFF6B81);
  static const focusRing = Color(0xFF7BBCF5);
}

/// Grilla de 4px.
class ClxSpace {
  ClxSpace._();
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;
  static const s16 = 64.0;
}

class ClxRadius {
  ClxRadius._();
  static const sm = 4.0; // casillas, etiquetas chicas
  static const md = 8.0; // botones, campos
  static const lg = 12.0; // tarjetas, avisos
  static const xl = 20.0; // diálogos, hojas inferiores
  static const pill = 999.0; // insignias, CTA de pantallas públicas
}

/// Sombras azuladas al estilo Stripe.
class ClxShadow {
  ClxShadow._();
  static const card = [
    BoxShadow(color: Color(0x1F32325D), offset: Offset(0, 2), blurRadius: 5, spreadRadius: -1),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 3, spreadRadius: -1),
  ];
  static const float = [
    BoxShadow(color: Color(0x1F32325D), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -2),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 3), blurRadius: 7, spreadRadius: -3),
  ];
}

/// Familias tipográficas (cargadas con google_fonts).
class ClxFonts {
  ClxFonts._();
  static const sans = 'Geist';
  static const mono = 'Source Code Pro'; // montos, códigos, IDs
}
