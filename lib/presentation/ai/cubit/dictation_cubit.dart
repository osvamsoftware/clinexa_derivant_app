import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/core/services/speech_service.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:equatable/equatable.dart';

enum DictationPhase {
  idle,

  /// Pidiendo permiso / preparando el micrófono.
  starting,
  listening,

  /// La IA ordena lo dictado.
  parsing,

  /// Hay campos propuestos para que el médico confirme.
  proposal,

  /// No hay permiso de micrófono o el teléfono no reconoce voz.
  unavailable,

  /// No se escuchó nada.
  empty,
  failure,
}

class DictationState extends Equatable {
  const DictationState({
    this.phase = DictationPhase.idle,
    this.transcript = '',
    this.level = 0,
    this.fields,
    this.error,
  });

  final DictationPhase phase;
  final String transcript;

  /// Nivel de voz 0..1 (para la onda).
  final double level;
  final DictationFields? fields;
  final AiException? error;

  DictationState copyWith({
    DictationPhase? phase,
    String? transcript,
    double? level,
    DictationFields? fields,
    AiException? error,
  }) => DictationState(
    phase: phase ?? this.phase,
    transcript: transcript ?? this.transcript,
    level: level ?? this.level,
    fields: fields ?? this.fields,
    error: error,
  );

  @override
  List<Object?> get props => [phase, transcript, level, fields, error];
}

/// IA-05 · Dictado: la voz se transcribe en el teléfono; al terminar, la IA
/// propone edad, sexo, patologías y notas (nunca nombre, documento ni
/// contacto). Con [parse] = false solo transcribe (IA-03).
class DictationCubit extends Cubit<DictationState> {
  DictationCubit(this._repository, this._speech, {this.parse = true})
    : super(const DictationState());

  final AiRepository _repository;
  final SpeechService _speech;
  final bool parse;

  Future<void> start() async {
    if (state.phase == DictationPhase.listening ||
        state.phase == DictationPhase.starting) {
      return;
    }
    emit(const DictationState(phase: DictationPhase.starting));
    final ok = await _speech.initialize();
    if (isClosed) return;
    if (!ok) {
      emit(const DictationState(phase: DictationPhase.unavailable));
      return;
    }
    emit(const DictationState(phase: DictationPhase.listening));
    await _speech.listen(
      onResult: (u) {
        if (!isClosed && state.phase == DictationPhase.listening) {
          emit(state.copyWith(transcript: u.text));
        }
      },
      onLevel: (l) {
        if (!isClosed && state.phase == DictationPhase.listening) {
          emit(state.copyWith(level: l));
        }
      },
      onDone: ({String? error}) => _onSpeechDone(error),
    );
  }

  /// El médico toca "Listo".
  Future<void> stop() async {
    if (state.phase != DictationPhase.listening) return;
    await _speech.stop();
    // Por si el motor no avisa al detenerse.
    if (!isClosed && state.phase == DictationPhase.listening) {
      _onSpeechDone(null);
    }
  }

  Future<void> cancel() async {
    await _speech.cancel();
    if (!isClosed) emit(const DictationState());
  }

  void _onSpeechDone(String? error) {
    if (isClosed || state.phase != DictationPhase.listening) return;
    final text = state.transcript.trim();
    if (text.isEmpty) {
      emit(
        DictationState(
          phase: error == null
              ? DictationPhase.empty
              : DictationPhase.unavailable,
        ),
      );
      return;
    }
    if (!parse) {
      emit(state.copyWith(phase: DictationPhase.idle, level: 0));
      return;
    }
    parseTranscript(text);
  }

  /// Llama a `parse-dictation` con el texto transcrito.
  Future<void> parseTranscript(String transcript) async {
    emit(DictationState(phase: DictationPhase.parsing, transcript: transcript));
    try {
      final fields = await _repository.parseDictation(transcript);
      if (!isClosed) {
        emit(state.copyWith(phase: DictationPhase.proposal, fields: fields));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: DictationPhase.failure,
            error: asAiException(e),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _speech.cancel();
    return super.close();
  }
}
