import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';

/// IA-07 · Consejos a partir de los rechazos de mis derivaciones.
class RejectionFeedbackCubit extends Cubit<AiRequestState<RejectionFeedback>> {
  RejectionFeedbackCubit(this._repository) : super(const AiRequestState());

  final AiRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;
    emit(state.loading());
    try {
      final result = await _repository.myRejections();
      if (!isClosed) emit(state.success(result));
    } catch (e) {
      if (!isClosed) emit(state.failure(asAiException(e)));
    }
  }
}
