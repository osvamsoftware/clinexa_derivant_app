import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:equatable/equatable.dart';

class EligibilityState extends Equatable {
  const EligibilityState({
    this.request = const AiRequestState(),
    this.corrections = const {},
    this.pathologies = const [],
    this.dictatedAge,
    this.attached = false,
  });

  final AiRequestState<EligibilityResult> request;

  /// Correcciones del médico por número de criterio.
  final Map<int, EligibilityStatus> corrections;

  /// Patologías del caso que solo usa la IA (el formulario no las tiene).
  final List<String> pathologies;

  /// Edad dictada, si todavía no hay fecha de nacimiento.
  final int? dictatedAge;
  final bool attached;

  EligibilityResult? get result => request.data;

  EligibilityStatus statusOf(EligibilityItem item) =>
      corrections[item.order] ?? item.status;

  bool isCorrected(EligibilityItem item) =>
      corrections.containsKey(item.order) &&
      corrections[item.order] != item.status;

  /// Hay al menos un criterio que no se cumple (con las correcciones).
  bool get hasFails =>
      result?.items.any((i) => statusOf(i) == EligibilityStatus.fails) ?? false;

  int get missingCount =>
      result?.items
          .where((i) => statusOf(i) == EligibilityStatus.missing)
          .length ??
      0;

  EligibilityState copyWith({
    AiRequestState<EligibilityResult>? request,
    Map<int, EligibilityStatus>? corrections,
    List<String>? pathologies,
    int? dictatedAge,
    bool? attached,
  }) => EligibilityState(
    request: request ?? this.request,
    corrections: corrections ?? this.corrections,
    pathologies: pathologies ?? this.pathologies,
    dictatedAge: dictatedAge ?? this.dictatedAge,
    attached: attached ?? this.attached,
  );

  @override
  List<Object?> get props => [
    request,
    corrections,
    pathologies,
    dictatedAge,
    attached,
  ];
}

/// IA-02 · Pre-evaluación de elegibilidad del caso, antes de enviar la
/// derivación. Advierte pero nunca bloquea: el médico decide.
class EligibilityCubit extends Cubit<EligibilityState> {
  EligibilityCubit(this._repository, {required this.protocolId})
    : super(const EligibilityState());

  final AiRepository _repository;
  final String? protocolId;

  /// Edad a partir de la fecha de nacimiento, o la dictada si no hay fecha.
  int? ageFor(DateTime? birthDate, {DateTime? now}) {
    if (birthDate == null) return state.dictatedAge;
    final today = now ?? DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  /// Valor del desplegable de sexo del formulario → valor de la API.
  static String? sexFromGender(String? gender) => switch (gender) {
    'Male' => 'male',
    'Female' => 'female',
    'Other' => 'other',
    _ => null,
  };

  void addPathology(String name) {
    final n = name.trim();
    if (n.isEmpty ||
        state.pathologies.any((p) => p.toLowerCase() == n.toLowerCase())) {
      return;
    }
    emit(state.copyWith(pathologies: [...state.pathologies, n]));
  }

  void addPathologies(Iterable<String> names) {
    for (final n in names) {
      addPathology(n);
    }
  }

  void removePathology(String name) => emit(
    state.copyWith(
      pathologies: state.pathologies.where((p) => p != name).toList(),
    ),
  );

  void setDictatedAge(int? age) {
    if (age == null || age < 0 || age > 120) return;
    emit(state.copyWith(dictatedAge: age));
  }

  Future<void> evaluate(AiCase aiCase) async {
    final id = protocolId;
    if (id == null || id.isEmpty || state.request.isLoading) return;
    emit(
      EligibilityState(
        request: const AiRequestState(status: AiRequestStatus.loading),
        pathologies: state.pathologies,
        dictatedAge: state.dictatedAge,
      ),
    );
    try {
      final result = await _repository.evaluateEligibility(
        protocolId: id,
        aiCase: aiCase,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            request: state.request.success(result),
            corrections: const {},
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(request: state.request.failure(asAiException(e))));
      }
    }
  }

  /// El médico corrige un criterio.
  void correct(int order, EligibilityStatus status) {
    final next = Map<int, EligibilityStatus>.from(state.corrections)
      ..[order] = status;
    emit(state.copyWith(corrections: next));
  }

  /// Vincula la evaluación al paciente recién registrado. Nunca lanza: si
  /// falla, la derivación ya está hecha y no se molesta al médico.
  Future<bool> attach(String patientId) async {
    final result = state.result;
    if (result == null ||
        result.eligibilityId.isEmpty ||
        state.attached ||
        patientId.isEmpty) {
      return false;
    }
    try {
      await _repository.attachEligibility(
        eligibilityId: result.eligibilityId,
        patientId: patientId,
        reviewed: {
          for (final item in result.items) item.order: state.statusOf(item),
        },
      );
      if (!isClosed) emit(state.copyWith(attached: true));
      return true;
    } catch (_) {
      return false;
    }
  }
}
