import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Un documento legal empaquetado con la app.
///
/// El contenido se genera desde los .docx del equipo legal con
/// `tool/build_legal.py` (repo del dashboard) y viaja como asset en vez de
/// pedirse por red: la autorización se firma en el consultorio, donde puede no
/// haber señal, y un documento que no carga es un documento que no se puede
/// aceptar.
class LegalDocument {
  /// Identifica al documento y nombra su asset y su página pública.
  final String slug;

  /// Título tal como figura en el texto legal.
  final String title;

  /// Qué regula, en una línea.
  final String summary;

  const LegalDocument({
    required this.slug,
    required this.title,
    required this.summary,
  });

  String get assetPath => 'assets/legal/$slug.json';
}

/// Una sección numerada del documento.
class LegalSection {
  final String heading;
  final List<String> paragraphs;

  const LegalSection({required this.heading, required this.paragraphs});

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      heading: json['heading'] as String? ?? '',
      paragraphs: (json['paragraphs'] as List<dynamic>? ?? const [])
          .map((p) => p as String)
          .toList(growable: false),
    );
  }
}

/// El texto completo de un documento, ya cargado desde el asset.
class LegalDocumentContent {
  final String slug;
  final String title;
  final String summary;

  /// Dónde está publicado el mismo documento, para poder abrirlo en el
  /// navegador o compartirlo.
  final String url;

  /// Párrafos previos a la primera sección (por ejemplo, la fecha de
  /// última actualización).
  final List<String> intro;

  final List<LegalSection> sections;

  const LegalDocumentContent({
    required this.slug,
    required this.title,
    required this.summary,
    required this.url,
    required this.intro,
    required this.sections,
  });

  factory LegalDocumentContent.fromJson(Map<String, dynamic> json) {
    return LegalDocumentContent(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      url: json['url'] as String? ?? '',
      intro: (json['intro'] as List<dynamic>? ?? const [])
          .map((p) => p as String)
          .toList(growable: false),
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map((s) => LegalSection.fromJson(s as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Lee un documento del bundle.
///
/// Falla con un mensaje explícito si el asset no está: significa que el
/// catálogo y los archivos generados quedaron desincronizados, y es mejor
/// verlo en desarrollo que servirle una pantalla vacía a un paciente.
Future<LegalDocumentContent> loadLegalDocument(LegalDocument document) async {
  final raw = await rootBundle.loadString(document.assetPath);
  return LegalDocumentContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
