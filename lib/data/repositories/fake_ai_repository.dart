import 'dart:async';
import 'dart:typed_data';

import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';

/// Repositorio de IA falso con respuestas del contrato
/// (clinexa_backend/docs/IA_APPS_CONTRATO.md).
///
/// Sirve para pruebas, capturas y para probar la app contra un backend que
/// todavía no tiene las rutas de IA. Solo se activa en debug con
/// `--dart-define=CLX_AI_FAKE=on` (ver `ManagerRepository`). Nunca en release.
///
/// Los campos públicos permiten forzar cada estado desde una prueba:
/// [enabled] (IA desactivada), [error] (respuesta con `detail`), [hang]
/// (la IA "piensa" para siempre) y [noRejections].
class FakeAiRepository implements AiRepository {
  FakeAiRepository({this.delay = const Duration(milliseconds: 900)});

  Duration delay;
  bool enabled = true;
  AiException? error;
  bool hang = false;
  bool noRejections = false;

  /// Llamadas recibidas (para las pruebas).
  final List<String> calls = [];
  Map<int, EligibilityStatus>? lastReviewed;
  String? lastAttachedPatientId;
  List<AssistantTurn>? lastHistory;
  String? lastProtocolId;

  static const errorDailyLimit = AiException(
    429,
    'Alcanzaste el límite diario de consultas a la IA. Vuelve a intentarlo mañana.',
  );

  Future<T> _answer<T>(String name, T Function() build) async {
    calls.add(name);
    if (hang) return Completer<T>().future;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final e = error;
    if (e != null) throw e;
    return build();
  }

  @override
  Future<AiStatus> status({bool refresh = false}) async {
    calls.add('status');
    return enabled
        ? const AiStatus(enabled: true, mode: 'simulated')
        : const AiStatus.disabled();
  }

  @override
  Future<EligibilityResult> evaluateEligibility({
    required String protocolId,
    required AiCase aiCase,
  }) => _answer('eligibility', () {
    lastProtocolId = protocolId;
    return EligibilityResult(
      eligibilityId: 'elig-demo-1',
      protocolId: protocolId,
      protocolName: 'Estudio DM2-OPT',
      fitScore: 74,
      mode: 'simulated',
      summary:
          'El caso cumple la mayoría de los criterios de inclusión. La HbA1c está en rango, '
          'pero falta confirmar la función renal y hay una posible exclusión por insulina.',
      items: const [
        EligibilityItem(
          order: 1,
          text: 'Edad entre 40 y 75 años',
          kind: 'inclusion',
          status: EligibilityStatus.meets,
          evidence: 'Edad informada: 58 años.',
        ),
        EligibilityItem(
          order: 2,
          text: 'Diagnóstico de diabetes tipo 2 de al menos 1 año',
          kind: 'inclusion',
          status: EligibilityStatus.meets,
          evidence: 'Notas: "DM2 diagnosticada en 2019".',
        ),
        EligibilityItem(
          order: 3,
          text: 'HbA1c entre 7.5 % y 10 %',
          kind: 'inclusion',
          status: EligibilityStatus.meets,
          evidence: 'HbA1c 8.2 % (10/11/2026).',
        ),
        EligibilityItem(
          order: 4,
          text: 'Filtrado glomerular ≥ 45 mL/min',
          kind: 'inclusion',
          status: EligibilityStatus.missing,
          evidence: 'No hay datos de función renal en el caso.',
        ),
        EligibilityItem(
          order: 5,
          text: 'Uso de insulina en los últimos 3 meses',
          kind: 'exclusion',
          status: EligibilityStatus.fails,
          evidence: 'Notas: "insulina NPH nocturna desde agosto".',
        ),
      ],
    );
  });

  @override
  Future<void> attachEligibility({
    required String eligibilityId,
    required String patientId,
    required Map<int, EligibilityStatus> reviewed,
  }) => _answer('attach', () {
    lastAttachedPatientId = patientId;
    lastReviewed = Map.of(reviewed);
  });

  @override
  Future<ProtocolSuggestions> suggestProtocols(String description) => _answer(
    'suggest',
    () => const ProtocolSuggestions(
      note:
          'Solo se consideran protocolos activos. Confirma los criterios antes de derivar.',
      suggestions: [
        ProtocolSuggestion(
          protocolId: 'demo-p1',
          name: 'Estudio DM2-OPT',
          score: 87,
          reason:
              'Mujer de 58 años con DM2 y HbA1c 8.2 %: dentro del rango de inclusión.',
          specialties: ['Endocrinología'],
          pathologies: ['Diabetes tipo 2'],
        ),
        ProtocolSuggestion(
          protocolId: 'demo-p2',
          name: 'CARDIO-MET 3',
          score: 64,
          reason:
              'Riesgo cardiovascular por DM2; falta confirmar antecedentes de evento coronario.',
          specialties: ['Cardiología'],
          pathologies: ['Diabetes tipo 2', 'Hipertensión arterial'],
        ),
        ProtocolSuggestion(
          protocolId: 'demo-p3',
          name: 'Registro de obesidad y metabolismo',
          score: 41,
          reason:
              'Podría aplicar si el IMC es mayor a 30; no se menciona en la descripción.',
          specialties: ['Nutrición'],
          pathologies: ['Obesidad'],
        ),
      ],
    ),
  );

  @override
  Future<DocumentExtraction> extractDocument({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) => _answer(
    'extract',
    () => const DocumentExtraction(
      findings: [
        DocumentFinding(
          label: 'HbA1c',
          value: '8.2',
          unit: '%',
          date: '2026-11-10',
        ),
        DocumentFinding(
          label: 'Glucosa en ayunas',
          value: '156',
          unit: 'mg/dL',
          date: '2026-11-10',
        ),
        DocumentFinding(
          label: 'Creatinina',
          value: '0.9',
          unit: 'mg/dL',
          date: '2026-11-10',
        ),
        DocumentFinding(
          label: 'Colesterol LDL',
          value: '128',
          unit: 'mg/dL',
          date: '2026-11-10',
        ),
      ],
      notesText:
          'Laboratorio del 10/11/2026: HbA1c 8.2 %, glucosa en ayunas 156 mg/dL, '
          'creatinina 0.9 mg/dL, colesterol LDL 128 mg/dL.',
      warnings: [
        'La fecha de la creatinina se tomó del encabezado del estudio.',
      ],
    ),
  );

  @override
  Future<DictationFields> parseDictation(String transcript) => _answer(
    'dictation',
    () => const DictationFields(
      age: 58,
      sex: 'female',
      pathologies: ['Diabetes tipo 2', 'Hipertensión arterial'],
      notes:
          'HbA1c 8.2 % en noviembre. Toma metformina 850 mg dos veces al día. Sin eventos cardiovasculares.',
      warnings: ['Se omitió el nombre que mencionaste: escríbelo a mano.'],
    ),
  );

  @override
  Future<RejectionFeedback> myRejections() => _answer('rejections', () {
    if (noRejections) {
      return const RejectionFeedback(
        total: 0,
        summary:
            'No tuviste rechazos en los últimos 12 meses. Tus derivaciones llegan completas.',
      );
    }
    return RejectionFeedback(
      total: 4,
      createdAt: DateTime(2026, 11, 20),
      summary:
          'En los últimos 12 meses te rechazaron 4 derivaciones. La mitad fue por datos de laboratorio '
          'faltantes; las demás, por criterios de exclusión que ya figuraban en las notas.',
      categories: const [
        RejectionCategory(
          name: 'Faltan estudios de laboratorio',
          count: 2,
          protocols: ['Estudio DM2-OPT', 'CARDIO-MET 3'],
          recommendation:
              'Agrega HbA1c y función renal recientes (menos de 3 meses) en las notas.',
        ),
        RejectionCategory(
          name: 'Criterio de exclusión presente',
          count: 1,
          protocols: ['Estudio DM2-OPT'],
          recommendation:
              'Revisa el uso de insulina antes de derivar a este protocolo.',
        ),
        RejectionCategory(
          name: 'Edad fuera de rango',
          count: 1,
          protocols: ['Registro de obesidad y metabolismo'],
          recommendation: 'Confirma la edad mínima y máxima del protocolo.',
        ),
      ],
    );
  });

  @override
  Future<AssistantAnswer> askAssistant({
    required String question,
    List<AssistantTurn> history = const [],
    String? protocolId,
  }) => _answer('assistant', () {
    lastHistory = List.of(history);
    lastProtocolId = protocolId;
    return const AssistantAnswer(
      answer:
          'Dos protocolos activos aceptan pacientes con insuficiencia renal leve: Estudio DM2-OPT '
          '(filtrado glomerular de 45 mL/min o más) y CARDIO-MET 3 (sin límite explícito, pero excluye diálisis). '
          'Ninguno acepta insuficiencia renal grave.',
      sources: [
        AssistantSource(
          protocolId: 'demo-p1',
          protocolName: 'Estudio DM2-OPT',
          excerpt: 'Criterio 4: filtrado glomerular ≥ 45 mL/min/1.73 m².',
        ),
        AssistantSource(
          protocolId: 'demo-p2',
          protocolName: 'CARDIO-MET 3',
          excerpt: 'Exclusión: pacientes en diálisis o con trasplante renal.',
        ),
      ],
      followUps: [
        '¿Qué estudios necesito para derivar a DM2-OPT?',
        '¿Qué protocolos aceptan pacientes mayores de 75 años?',
      ],
    );
  });
}
