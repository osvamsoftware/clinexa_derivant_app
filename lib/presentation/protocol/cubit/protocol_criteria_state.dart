import 'package:clinexa_derivant_app/data/models/criterion_model.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:equatable/equatable.dart';

enum CriteriaStatus { initial, validating, stepSuccess, completed }

class ProtocolCriteriaState extends Equatable {
  final ProtocolModel protocol;
  final int currentStep;
  final Set<String> checkedCriteriaIds;
  final String? errorMessage;
  final CriteriaStatus status;

  // Derived properties
  List<CriterionModel> get allCriteria => protocol.criteria;

  // Logic for step pagination (5 per step)
  static const int itemsPerStep = 5;

  int get totalSteps => (protocol.criteria.length / itemsPerStep).ceil();

  List<CriterionModel> get currentStepCriteria {
    final startIndex = (currentStep - 1) * itemsPerStep;
    final endIndex = startIndex + itemsPerStep;
    if (startIndex >= protocol.criteria.length) return [];

    return protocol.criteria.sublist(
      startIndex,
      endIndex > protocol.criteria.length ? protocol.criteria.length : endIndex,
    );
  }

  bool get isLastStep => currentStep >= totalSteps;

  const ProtocolCriteriaState({
    required this.protocol,
    this.currentStep = 1,
    this.checkedCriteriaIds = const {},
    this.errorMessage,
    this.status = CriteriaStatus.initial,
  });

  ProtocolCriteriaState copyWith({
    ProtocolModel? protocol,
    int? currentStep,
    Set<String>? checkedCriteriaIds,
    String? errorMessage,
    CriteriaStatus? status,
  }) {
    return ProtocolCriteriaState(
      protocol: protocol ?? this.protocol,
      currentStep: currentStep ?? this.currentStep,
      checkedCriteriaIds: checkedCriteriaIds ?? this.checkedCriteriaIds,
      errorMessage:
          errorMessage, // Reset error on change if null passed? No, optional.
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    protocol,
    currentStep,
    checkedCriteriaIds,
    errorMessage,
    status,
  ];
}
