import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:equatable/equatable.dart';

class AssistantMessage extends Equatable {
  const AssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    this.sources = const [],
    this.followUps = const [],
  });

  final int id;

  /// `user` o `assistant`.
  final String role;
  final String content;
  final List<AssistantSource> sources;
  final List<String> followUps;

  bool get fromUser => role == 'user';

  @override
  List<Object?> get props => [id, role, content, sources, followUps];
}

class AssistantState extends Equatable {
  const AssistantState({
    this.messages = const [],
    this.loading = false,
    this.error,
    this.pendingQuestion,
  });

  final List<AssistantMessage> messages;
  final bool loading;
  final AiException? error;

  /// Pregunta que falló (para reintentar).
  final String? pendingQuestion;

  @override
  List<Object?> get props => [messages, loading, error, pendingQuestion];
}

/// IA-09 · Asistente de protocolos. La conversación vive solo en memoria y
/// al backend viajan los últimos 6 mensajes.
class AssistantCubit extends Cubit<AssistantState> {
  AssistantCubit(this._repository, {this.protocolId})
    : super(const AssistantState());

  final AiRepository _repository;

  /// Si se abrió desde un protocolo, las respuestas se centran en él.
  final String? protocolId;
  int _nextId = 0;

  Future<void> ask(String question) async {
    // El backend admite preguntas de 3 a 500 caracteres.
    final t = question.trim();
    final q = t.length > 500 ? t.substring(0, 500) : t;
    if (q.length < 3 || state.loading) return;
    final previous = state.messages;
    final user = AssistantMessage(id: _nextId++, role: 'user', content: q);
    await _send(q, previous, [...previous, user]);
  }

  /// Reintenta la última pregunta que falló (sin repetirla en el chat).
  Future<void> retry() async {
    final q = state.pendingQuestion;
    if (q == null || state.loading) return;
    final previous = state.messages.sublist(0, state.messages.length - 1);
    await _send(q, previous, state.messages);
  }

  Future<void> _send(
    String q,
    List<AssistantMessage> previous,
    List<AssistantMessage> shown,
  ) async {
    emit(AssistantState(messages: shown, loading: true));
    final history = trimAssistantHistory([
      for (final m in previous) AssistantTurn(role: m.role, content: m.content),
    ]);
    try {
      final a = await _repository.askAssistant(
        question: q,
        history: history,
        protocolId: protocolId,
      );
      if (isClosed) return;
      emit(
        AssistantState(
          messages: [
            ...shown,
            AssistantMessage(
              id: _nextId++,
              role: 'assistant',
              content: a.answer,
              sources: a.sources,
              followUps: a.followUps,
            ),
          ],
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          AssistantState(
            messages: shown,
            error: asAiException(e),
            pendingQuestion: q,
          ),
        );
      }
    }
  }

  void clear() => emit(const AssistantState());
}
