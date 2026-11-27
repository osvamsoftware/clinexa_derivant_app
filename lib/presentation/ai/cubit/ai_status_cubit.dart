import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';

enum AiAvailability { unknown, enabled, disabled }

/// Si la IA está disponible (`GET /ai/app/status`, cacheado en el
/// repositorio). Mientras no se sabe, o si está apagada, la app se ve y
/// funciona como antes de la IA.
class AiStatusCubit extends Cubit<AiAvailability> {
  AiStatusCubit(this._repository) : super(AiAvailability.unknown);

  final AiRepository _repository;

  Future<void> ensureLoaded({bool refresh = false}) async {
    final status = await _repository.status(refresh: refresh);
    if (isClosed) return;
    emit(status.enabled ? AiAvailability.enabled : AiAvailability.disabled);
  }
}
