import 'package:clinexa_derivant_app/core/legal/legal_catalog.dart';
import 'package:clinexa_derivant_app/core/legal/legal_document.dart';
import 'package:flutter/material.dart';

/// Muestra el texto completo de un documento legal.
///
/// Lee el asset empaquetado, así que funciona sin conexión.
class LegalDocumentScreen extends StatelessWidget {
  static const path = '/legal';

  /// Se recibe el slug por la ruta para poder enlazar cualquier documento sin
  /// tener que declarar una pantalla por cada uno.
  final String slug;

  const LegalDocumentScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final LegalDocument document;
    try {
      document = LegalCatalog.bySlug(slug);
    } on ArgumentError {
      return const Scaffold(
        body: _LegalError(
          message: 'El documento solicitado no existe en esta app.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Documento legal')),
      body: FutureBuilder<LegalDocumentContent>(
        future: loadLegalDocument(document),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const _LegalError(
              message:
                  'No se pudo cargar el documento. Actualiza la app e '
                  'inténtalo de nuevo.',
            );
          }

          return _LegalDocumentView(content: snapshot.requireData);
        },
      ),
    );
  }
}

class _LegalDocumentView extends StatelessWidget {
  final LegalDocumentContent content;

  const _LegalDocumentView({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // El texto se deja seleccionable: es un documento legal y el usuario tiene
    // derecho a copiar lo que acepta.
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          Text(
            content.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          for (final paragraph in content.intro) ...[
            Text(paragraph, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],
          for (final section in content.sections) ...[
            const SizedBox(height: 16),
            Text(
              section.heading,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            for (final paragraph in section.paragraphs) ...[
              Text(
                paragraph,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _LegalError extends StatelessWidget {
  final String message;

  const _LegalError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}
