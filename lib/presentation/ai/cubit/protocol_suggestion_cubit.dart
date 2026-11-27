import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';

/// IA-03 · Sugerencia de protocolos a partir de la descripción del caso.
class ProtocolSuggestionCubit
    extends Cubit<AiRequestState<ProtocolSuggestions>> {
  ProtocolSuggestionCubit(this._repository) : super(const AiRequestState());

  final AiRepository _repository;

  Future<void> suggest(String description) async {
    final text = description.trim();
    if (text.length < 5 || state.isLoading) return;
    emit(state.loading());
    try {
      final result = await _repository.suggestProtocols(text);
      if (!isClosed) emit(state.success(result));
    } catch (e) {
      if (!isClosed) emit(state.failure(asAiException(e)));
    }
  }

  void reset() => emit(const AiRequestState());
}
