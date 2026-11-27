import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:equatable/equatable.dart';

enum AiRequestStatus { idle, loading, success, failure }

/// Estado común de una consulta a la IA: en espera, pensando, resultado o
/// error (con el `detail` del backend).
class AiRequestState<T> extends Equatable {
  const AiRequestState({
    this.status = AiRequestStatus.idle,
    this.data,
    this.error,
  });

  final AiRequestStatus status;
  final T? data;
  final AiException? error;

  bool get isLoading => status == AiRequestStatus.loading;

  AiRequestState<T> loading() =>
      AiRequestState<T>(status: AiRequestStatus.loading, data: data);
  AiRequestState<T> success(T value) =>
      AiRequestState<T>(status: AiRequestStatus.success, data: value);
  AiRequestState<T> failure(AiException e) =>
      AiRequestState<T>(status: AiRequestStatus.failure, data: data, error: e);

  @override
  List<Object?> get props => [status, data, error];
}

/// Convierte cualquier error en [AiException] (sin red = código 0).
AiException asAiException(Object e) =>
    e is AiException ? e : const AiException(0);
