// Modelos de las funciones de IA de la app (rutas `/ai/app/*`).
//
// Contrato: clinexa_backend/docs/IA_APPS_CONTRATO.md. Todo resultado es una
// sugerencia: el médico revisa y confirma.
import 'package:equatable/equatable.dart';

List<String> _strings(dynamic v) => v is List
    ? v.map((e) => '$e').where((e) => e.isNotEmpty).toList()
    : const [];

int? _int(dynamic v) => v is num ? v.round() : int.tryParse('${v ?? ''}');

String _str(dynamic v) => v == null ? '' : '$v';

/// `GET /ai/app/status`.
class AiStatus extends Equatable {
  const AiStatus({required this.enabled, this.mode = ''});

  /// Backend sin las rutas de IA (404) o IA apagada.
  const AiStatus.disabled() : enabled = false, mode = '';

  final bool enabled;

  /// `live` o `simulated`.
  final String mode;

  factory AiStatus.fromMap(Map<String, dynamic> map) =>
      AiStatus(enabled: map['enabled'] == true, mode: _str(map['mode']));

  @override
  List<Object?> get props => [enabled, mode];
}

// =============================================================
// IA-02 · Pre-evaluación de elegibilidad
// =============================================================

enum EligibilityStatus {
  meets,
  fails,
  missing;

  static EligibilityStatus fromString(String? v) => switch (v) {
    'meets' => EligibilityStatus.meets,
    'fails' => EligibilityStatus.fails,
    _ => EligibilityStatus.missing,
  };

  String get apiValue => name;
}

/// Caso que se evalúa (el paciente todavía no existe).
class AiCase extends Equatable {
  const AiCase({
    this.age,
    this.sex,
    this.pathologies = const [],
    this.notes = '',
  });

  final int? age;

  /// `male`, `female` u `other`.
  final String? sex;
  final List<String> pathologies;
  final String notes;

  bool get isEmpty =>
      age == null && sex == null && pathologies.isEmpty && notes.trim().isEmpty;

  Map<String, dynamic> toMap() => {
    'age': age,
    'sex': sex,
    'pathologies': pathologies,
    'notes': notes,
  };

  @override
  List<Object?> get props => [age, sex, pathologies, notes];
}

class EligibilityItem extends Equatable {
  const EligibilityItem({
    required this.order,
    required this.text,
    required this.kind,
    required this.status,
    required this.evidence,
  });

  final int order;
  final String text;

  /// `inclusion` o `exclusion`.
  final String kind;
  final EligibilityStatus status;
  final String evidence;

  bool get isExclusion => kind == 'exclusion';

  factory EligibilityItem.fromMap(Map<String, dynamic> map) => EligibilityItem(
    order: _int(map['order']) ?? 0,
    text: _str(map['text']),
    kind: _str(map['kind']),
    status: EligibilityStatus.fromString(map['status'] as String?),
    evidence: _str(map['evidence']),
  );

  @override
  List<Object?> get props => [order, text, kind, status, evidence];
}

class EligibilityResult extends Equatable {
  const EligibilityResult({
    required this.eligibilityId,
    required this.protocolId,
    required this.protocolName,
    required this.fitScore,
    required this.summary,
    required this.items,
    this.mode = '',
  });

  final String eligibilityId;
  final String protocolId;
  final String protocolName;
  final int fitScore;
  final String summary;
  final List<EligibilityItem> items;
  final String mode;

  factory EligibilityResult.fromMap(Map<String, dynamic> map) =>
      EligibilityResult(
        eligibilityId: _str(map['eligibility_id']),
        protocolId: _str(map['protocol_id']),
        protocolName: _str(map['protocol_name']),
        fitScore: (_int(map['fit_score']) ?? 0).clamp(0, 100),
        summary: _str(map['summary']),
        mode: _str(map['mode']),
        items: (map['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => EligibilityItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );

  @override
  List<Object?> get props => [
    eligibilityId,
    protocolId,
    protocolName,
    fitScore,
    summary,
    items,
    mode,
  ];
}

// =============================================================
// IA-03 · Sugerencia de protocolos
// =============================================================

class ProtocolSuggestion extends Equatable {
  const ProtocolSuggestion({
    required this.protocolId,
    required this.name,
    required this.score,
    required this.reason,
    this.specialties = const [],
    this.pathologies = const [],
  });

  final String protocolId;
  final String name;
  final int score;
  final String reason;
  final List<String> specialties;
  final List<String> pathologies;

  factory ProtocolSuggestion.fromMap(Map<String, dynamic> map) =>
      ProtocolSuggestion(
        protocolId: _str(map['protocol_id']),
        name: _str(map['name']),
        score: (_int(map['score']) ?? 0).clamp(0, 100),
        reason: _str(map['reason']),
        specialties: _strings(map['specialties']),
        pathologies: _strings(map['pathologies']),
      );

  @override
  List<Object?> get props => [
    protocolId,
    name,
    score,
    reason,
    specialties,
    pathologies,
  ];
}

class ProtocolSuggestions extends Equatable {
  const ProtocolSuggestions({required this.suggestions, this.note = ''});

  final List<ProtocolSuggestion> suggestions;
  final String note;

  factory ProtocolSuggestions.fromMap(Map<String, dynamic> map) =>
      ProtocolSuggestions(
        note: _str(map['note']),
        suggestions: (map['suggestions'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (e) => ProtocolSuggestion.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );

  @override
  List<Object?> get props => [suggestions, note];
}

// =============================================================
// IA-04 · Lectura de estudios
// =============================================================

class DocumentFinding extends Equatable {
  const DocumentFinding({
    required this.label,
    required this.value,
    this.unit = '',
    this.date = '',
  });

  final String label;
  final String value;
  final String unit;
  final String date;

  factory DocumentFinding.fromMap(Map<String, dynamic> map) => DocumentFinding(
    label: _str(map['label']),
    value: _str(map['value']),
    unit: _str(map['unit']),
    date: _str(map['date']),
  );

  @override
  List<Object?> get props => [label, value, unit, date];
}

class DocumentExtraction extends Equatable {
  const DocumentExtraction({
    required this.findings,
    required this.notesText,
    this.warnings = const [],
  });

  final List<DocumentFinding> findings;
  final String notesText;
  final List<String> warnings;

  factory DocumentExtraction.fromMap(Map<String, dynamic> map) =>
      DocumentExtraction(
        notesText: _str(map['notes_text']),
        warnings: _strings(map['warnings']),
        findings: (map['findings'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => DocumentFinding.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );

  @override
  List<Object?> get props => [findings, notesText, warnings];
}

// =============================================================
// IA-05 · Dictado
// =============================================================

class DictationFields extends Equatable {
  const DictationFields({
    this.age,
    this.sex,
    this.pathologies = const [],
    this.notes = '',
    this.warnings = const [],
  });

  final int? age;
  final String? sex;
  final List<String> pathologies;
  final String notes;
  final List<String> warnings;

  bool get isEmpty =>
      age == null &&
      (sex == null || sex!.isEmpty) &&
      pathologies.isEmpty &&
      notes.trim().isEmpty;

  factory DictationFields.fromMap(Map<String, dynamic> map) {
    final f = map['fields'] is Map
        ? Map<String, dynamic>.from(map['fields'] as Map)
        : <String, dynamic>{};
    final sex = f['sex'] == null ? null : _str(f['sex']);
    return DictationFields(
      age: _int(f['age']),
      sex: (sex == null || sex.isEmpty) ? null : sex,
      pathologies: _strings(f['pathologies']),
      notes: _str(f['notes']),
      warnings: _strings(map['warnings']),
    );
  }

  @override
  List<Object?> get props => [age, sex, pathologies, notes, warnings];
}

// =============================================================
// IA-07 · Retroalimentación de rechazos
// =============================================================

class RejectionCategory extends Equatable {
  const RejectionCategory({
    required this.name,
    required this.count,
    this.protocols = const [],
    this.recommendation = '',
  });

  final String name;
  final int count;
  final List<String> protocols;
  final String recommendation;

  factory RejectionCategory.fromMap(Map<String, dynamic> map) =>
      RejectionCategory(
        name: _str(map['name']),
        count: _int(map['count']) ?? 0,
        protocols: _strings(map['protocols']),
        recommendation: _str(map['recommendation']),
      );

  @override
  List<Object?> get props => [name, count, protocols, recommendation];
}

class RejectionFeedback extends Equatable {
  const RejectionFeedback({
    required this.total,
    required this.summary,
    this.categories = const [],
    this.createdAt,
  });

  final int total;
  final String summary;
  final List<RejectionCategory> categories;
  final DateTime? createdAt;

  factory RejectionFeedback.fromMap(Map<String, dynamic> map) =>
      RejectionFeedback(
        total: _int(map['total']) ?? 0,
        summary: _str(map['summary']),
        createdAt: DateTime.tryParse(_str(map['created_at'])),
        categories: (map['categories'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => RejectionCategory.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );

  @override
  List<Object?> get props => [total, summary, categories, createdAt];
}

// =============================================================
// IA-09 · Asistente de protocolos
// =============================================================

class AssistantTurn extends Equatable {
  const AssistantTurn({required this.role, required this.content});

  /// `user` o `assistant`.
  final String role;
  final String content;

  Map<String, dynamic> toMap() => {'role': role, 'content': content};

  @override
  List<Object?> get props => [role, content];
}

class AssistantSource extends Equatable {
  const AssistantSource({
    required this.protocolId,
    required this.protocolName,
    required this.excerpt,
  });

  final String protocolId;
  final String protocolName;
  final String excerpt;

  factory AssistantSource.fromMap(Map<String, dynamic> map) => AssistantSource(
    protocolId: _str(map['protocol_id']),
    protocolName: _str(map['protocol_name']),
    excerpt: _str(map['excerpt']),
  );

  @override
  List<Object?> get props => [protocolId, protocolName, excerpt];
}

class AssistantAnswer extends Equatable {
  const AssistantAnswer({
    required this.answer,
    this.sources = const [],
    this.followUps = const [],
  });

  final String answer;
  final List<AssistantSource> sources;
  final List<String> followUps;

  factory AssistantAnswer.fromMap(Map<String, dynamic> map) => AssistantAnswer(
    answer: _str(map['answer']),
    followUps: _strings(map['follow_ups']),
    sources: (map['sources'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AssistantSource.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );

  @override
  List<Object?> get props => [answer, sources, followUps];
}
