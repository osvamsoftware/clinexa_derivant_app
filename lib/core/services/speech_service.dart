import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Resultado parcial o final del reconocimiento de voz.
class SpeechUpdate {
  const SpeechUpdate(this.text, {this.isFinal = false});
  final String text;
  final bool isFinal;
}

/// Reconocimiento de voz en el teléfono (IA-05). La voz nunca sale del
/// dispositivo: solo se envía el texto transcrito, y el backend lo anonimiza.
abstract class SpeechService {
  /// Pide permisos y prepara el motor. False si no hay permiso o el
  /// teléfono no tiene reconocimiento de voz.
  Future<bool> initialize();

  /// Empieza a escuchar en español. [onDone] se llama cuando el motor se
  /// detiene solo (silencio) o por error ([error] no nulo).
  Future<void> listen({
    required void Function(SpeechUpdate update) onResult,
    void Function(double level)? onLevel,
    void Function({String? error})? onDone,
  });

  Future<void> stop();
  Future<void> cancel();
}

/// Implementación con `speech_to_text` (motor del sistema).
class SystemSpeechService implements SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;
  String? _localeId;
  void Function({String? error})? _onDone;

  @override
  Future<bool> initialize() async {
    if (_ready) return true;
    try {
      _ready = await _stt.initialize(
        onError: (SpeechRecognitionError e) {
          // "no match" = no se escuchó nada: no es un error para mostrar.
          final silent =
              e.errorMsg.contains('no_match') ||
              e.errorMsg.contains('speech_timeout');
          _finish(error: silent ? null : e.errorMsg);
        },
        onStatus: (status) {
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _finish();
          }
        },
      );
      if (_ready) _localeId = await _spanishLocale();
    } catch (e) {
      debugPrint('No se pudo iniciar el reconocimiento de voz: $e');
      _ready = false;
    }
    return _ready;
  }

  /// Español del sistema si lo hay; si no, el primer español disponible.
  Future<String?> _spanishLocale() async {
    final system = await _stt.systemLocale();
    if (system != null && system.localeId.toLowerCase().startsWith('es')) {
      return system.localeId;
    }
    final all = await _stt.locales();
    const preferred = [
      'es_MX',
      'es-MX',
      'es_419',
      'es-419',
      'es_US',
      'es-US',
      'es_AR',
      'es-AR',
      'es_ES',
      'es-ES',
    ];
    for (final p in preferred) {
      if (all.any((l) => l.localeId == p)) return p;
    }
    for (final l in all) {
      if (l.localeId.toLowerCase().startsWith('es')) return l.localeId;
    }
    return 'es_MX';
  }

  void _finish({String? error}) {
    final cb = _onDone;
    _onDone = null;
    cb?.call(error: error);
  }

  @override
  Future<void> listen({
    required void Function(SpeechUpdate update) onResult,
    void Function(double level)? onLevel,
    void Function({String? error})? onDone,
  }) async {
    _onDone = onDone;
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) =>
          onResult(SpeechUpdate(r.recognizedWords, isFinal: r.finalResult)),
      // El nivel llega aprox. en -2..10 dB: se normaliza a 0..1.
      onSoundLevelChange: onLevel == null
          ? null
          : (db) => onLevel(((db + 2) / 12).clamp(0.0, 1.0)),
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        pauseFor: const Duration(seconds: 4),
        listenFor: const Duration(minutes: 2),
      ),
    );
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  Future<void> cancel() async {
    _onDone = null;
    await _stt.cancel();
  }
}

/// Dictado simulado para pruebas y capturas: va "escuchando" [script]
/// palabra por palabra.
class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    this.script =
        'Paciente mujer de 58 años con diabetes tipo 2 e hipertensión. HbA1c de 8.2 en noviembre, '
        'toma metformina 850 dos veces al día, sin eventos cardiovasculares.',
    this.available = true,
    this.wordInterval = const Duration(milliseconds: 140),
    this.autoFinish = true,
  });

  final String script;
  bool available;
  Duration wordInterval;

  /// Si es false, se queda escuchando con el texto completo hasta [stop].
  bool autoFinish;
  Timer? _timer;
  void Function({String? error})? _onDone;
  void Function(SpeechUpdate)? _onResult;
  String _current = '';

  @override
  Future<bool> initialize() async => available;

  @override
  Future<void> listen({
    required void Function(SpeechUpdate update) onResult,
    void Function(double level)? onLevel,
    void Function({String? error})? onDone,
  }) async {
    _onDone = onDone;
    _onResult = onResult;
    final words = script.split(' ');
    var i = 0;
    _timer?.cancel();
    _timer = Timer.periodic(wordInterval, (t) {
      if (i < words.length) {
        i++;
        _current = words.take(i).join(' ');
        onResult(SpeechUpdate(_current));
        onLevel?.call(0.3 + (i % 5) * 0.15);
      } else if (autoFinish) {
        t.cancel();
        onResult(SpeechUpdate(_current, isFinal: true));
        _done();
      } else {
        t.cancel();
      }
    });
  }

  void _done() {
    final cb = _onDone;
    _onDone = null;
    cb?.call();
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _onResult?.call(SpeechUpdate(_current, isFinal: true));
    _done();
  }

  @override
  Future<void> cancel() async {
    _timer?.cancel();
    _onDone = null;
  }
}
