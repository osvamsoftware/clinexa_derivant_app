import 'package:clinexa_derivant_app/core/legal/legal_catalog.dart';
import 'package:clinexa_derivant_app/core/legal/legal_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // rootBundle necesita que el binding esté inicializado para resolver assets.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Documentos legales empaquetados', () {
    test('todos los documentos del catálogo se pueden cargar', () async {
      // El catálogo y los assets se generan por separado (tool/build_legal.py
      // vive en el repo del dashboard). Si se desincronizan, el paciente se
      // encontraría con una pantalla de error justo antes de firmar.
      for (final document in LegalCatalog.all) {
        final content = await loadLegalDocument(document);

        expect(
          content.slug,
          document.slug,
          reason: 'El asset de ${document.slug} contiene otro documento.',
        );
        expect(
          content.sections,
          isNotEmpty,
          reason: '${document.slug} no tiene secciones: revisa el generador.',
        );
      }
    });

    test('ninguna sección queda sin texto', () async {
      for (final document in LegalCatalog.all) {
        final content = await loadLegalDocument(document);

        for (final section in content.sections) {
          expect(section.heading, isNotEmpty, reason: document.slug);
          expect(
            section.paragraphs,
            isNotEmpty,
            reason: '${document.slug} → "${section.heading}" quedó vacía.',
          );
        }
      }
    });

    test('la autorización del paciente está disponible', () async {
      // Es la que se abre desde la pantalla de firma; sin ella el paciente
      // firmaría algo que no puede leer.
      final content = await loadLegalDocument(
        LegalCatalog.patientAuthorization,
      );
      expect(content.title, contains('Autorización'));
    });

    test('bySlug encuentra cada documento y rechaza los desconocidos', () {
      for (final document in LegalCatalog.all) {
        expect(LegalCatalog.bySlug(document.slug).slug, document.slug);
      }
      expect(
        () => LegalCatalog.bySlug('no-existe'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
