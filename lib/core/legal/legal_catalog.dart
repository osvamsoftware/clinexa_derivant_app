import 'package:clinexa_derivant_app/core/legal/legal_document.dart';

/// Documentos legales que aplican al Médico Referente y a sus pacientes.
///
/// Debe mantenerse sincronizado con `DOCUMENTOS_POR_APP` en
/// `tool/build_legal.py` (repo del dashboard), que es quien genera los assets.
class LegalCatalog {
  const LegalCatalog._();

  /// Términos que el Médico Referente acepta al crear su cuenta.
  static const referentTerms = LegalDocument(
    slug: 'terminos-medico-referente',
    title: 'Términos y Condiciones del Médico Referente',
    summary:
        'Condiciones de registro y uso de la plataforma para los profesionales '
        'médicos que derivan y postulan pacientes.',
  );

  /// Términos que se ratifican en cada postulación de un paciente.
  static const patientReferralTerms = LegalDocument(
    slug: 'terminos-postulacion-paciente',
    title: 'Términos Específicos para la Postulación de Pacientes',
    summary:
        'Declaraciones y obligaciones que el Médico Referente ratifica en cada '
        'postulación individual de un paciente.',
  );

  /// Consentimiento que el paciente firma antes de ser postulado.
  static const patientAuthorization = LegalDocument(
    slug: 'autorizacion-paciente',
    title: 'Autorización del Paciente',
    summary:
        'Consentimiento informado del paciente para el tratamiento de sus datos '
        'personales y de salud dentro de la plataforma.',
  );

  static const privacyPolicy = LegalDocument(
    slug: 'privacidad',
    title: 'Política de Privacidad',
    summary:
        'Cómo Clinexapp recolecta, usa, protege y elimina los datos personales '
        'y los datos sensibles de salud tratados en la plataforma.',
  );

  /// Todos los documentos, en el orden en que se listan en la cuenta.
  static const all = [
    referentTerms,
    patientReferralTerms,
    patientAuthorization,
    privacyPolicy,
  ];

  static LegalDocument bySlug(String slug) {
    return all.firstWhere(
      (document) => document.slug == slug,
      orElse: () => throw ArgumentError('Documento legal desconocido: $slug'),
    );
  }
}
