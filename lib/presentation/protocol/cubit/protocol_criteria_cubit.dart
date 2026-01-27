import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_criteria_state.dart';

class ProtocolCriteriaCubit extends Cubit<ProtocolCriteriaState> {
  ProtocolCriteriaCubit(ProtocolModel protocol)
    : super(ProtocolCriteriaState(protocol: protocol));

  void toggleCriteria(String criteriaId) {
    final newCheckedIds = Set<String>.from(state.checkedCriteriaIds);
    if (newCheckedIds.contains(criteriaId)) {
      newCheckedIds.remove(criteriaId);
    } else {
      newCheckedIds.add(criteriaId);
    }

    emit(state.copyWith(checkedCriteriaIds: newCheckedIds));
  }

  void nextStep() {
    // Validate current step
    final currentCriteria = state.currentStepCriteria;
    final allChecked = currentCriteria.every(
      (c) => state.checkedCriteriaIds.contains(c.text),
    );

    if (!allChecked) {
      emit(
        state.copyWith(
          status: CriteriaStatus.initial,
          errorMessage: "ERROR_CRITERIA_NOT_MET",
        ),
      );
      // Re-emit validation failure if needed
      return;
    }

    if (state.isLastStep) {
      emit(state.copyWith(status: CriteriaStatus.completed));
    } else {
      emit(
        state.copyWith(
          currentStep: state.currentStep + 1,
          status: CriteriaStatus.stepSuccess,
        ),
      );
    }
  }

  void resetError() {
    emit(state.copyWith(errorMessage: null));
  }
}
