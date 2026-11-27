import 'dart:typed_data';

import 'package:clinexa_derivant_app/core/services/speech_service.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/data/repositories/fake_ai_repository.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_status_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/assistant_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/dictation_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/document_extraction_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/eligibility_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/protocol_suggestion_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/rejection_feedback_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAiRepository repo;

  setUp(() => repo = FakeAiRepository(delay: Duration.zero));

  group('AiStatusCubit', () {
    test('habilitada', () async {
      final c = AiStatusCubit(repo);
      expect(c.state, AiAvailability.unknown);
      await c.ensureLoaded();
      expect(c.state, AiAvailability.enabled);
    });

    test('desactivada', () async {
      repo.enabled = false;
      final c = AiStatusCubit(repo);
      await c.ensureLoaded();
      expect(c.state, AiAvailability.disabled);
    });
  });

  group('EligibilityCubit', () {
    test('evalúa, detecta "No cumple" y faltantes', () async {
      final c = EligibilityCubit(repo, protocolId: 'p1');
      await c.evaluate(const AiCase(age: 58, sex: 'female', notes: 'x'));
      expect(c.state.request.status, AiRequestStatus.success);
      expect(repo.lastProtocolId, 'p1');
      expect(c.state.hasFails, isTrue);
      expect(c.state.missingCount, 1);
    });

    test(
      'el médico corrige: deja de advertir y attach manda sus correcciones',
      () async {
        final c = EligibilityCubit(repo, protocolId: 'p1');
        await c.evaluate(const AiCase(age: 58));
        c.correct(5, EligibilityStatus.meets);
        c.correct(4, EligibilityStatus.meets);
        expect(c.state.hasFails, isFalse);
        expect(c.state.missingCount, 0);
        final item5 = c.state.result!.items.firstWhere((i) => i.order == 5);
        expect(c.state.isCorrected(item5), isTrue);

        expect(await c.attach('pac-1'), isTrue);
        expect(repo.lastAttachedPatientId, 'pac-1');
        expect(repo.lastReviewed, {
          1: EligibilityStatus.meets,
          2: EligibilityStatus.meets,
          3: EligibilityStatus.meets,
          4: EligibilityStatus.meets,
          5: EligibilityStatus.meets,
        });
        expect(c.state.attached, isTrue);
        // Solo una vez.
        expect(await c.attach('pac-1'), isFalse);
      },
    );

    test('sin evaluación no vincula nada', () async {
      final c = EligibilityCubit(repo, protocolId: 'p1');
      expect(await c.attach('pac-1'), isFalse);
      expect(repo.calls, isNot(contains('attach')));
    });

    test('attach nunca lanza aunque falle el backend', () async {
      final c = EligibilityCubit(repo, protocolId: 'p1');
      await c.evaluate(const AiCase(age: 58));
      repo.error = FakeAiRepository.errorDailyLimit;
      expect(await c.attach('pac-1'), isFalse);
    });

    test('error: conserva el detail', () async {
      repo.error = FakeAiRepository.errorDailyLimit;
      final c = EligibilityCubit(repo, protocolId: 'p1');
      await c.evaluate(const AiCase(age: 58));
      expect(c.state.request.status, AiRequestStatus.failure);
      expect(c.state.request.error!.detail, contains('límite diario'));
    });

    test('edad desde la fecha de nacimiento o la dictada', () {
      final c = EligibilityCubit(repo, protocolId: 'p1');
      expect(c.ageFor(DateTime(1968, 12, 1), now: DateTime(2026, 11, 27)), 57);
      expect(c.ageFor(DateTime(1968, 11, 27), now: DateTime(2026, 11, 27)), 58);
      expect(c.ageFor(null), isNull);
      c.setDictatedAge(61);
      expect(c.ageFor(null), 61);
    });

    test('patologías sin duplicados', () {
      final c = EligibilityCubit(repo, protocolId: 'p1');
      c.addPathologies(['DM2', 'dm2', ' HTA ', '']);
      expect(c.state.pathologies, ['DM2', 'HTA']);
      c.removePathology('DM2');
      expect(c.state.pathologies, ['HTA']);
    });

    test('sexo del formulario → API', () {
      expect(EligibilityCubit.sexFromGender('Female'), 'female');
      expect(EligibilityCubit.sexFromGender('Male'), 'male');
      expect(EligibilityCubit.sexFromGender(null), isNull);
    });
  });

  group('ProtocolSuggestionCubit', () {
    test('sugiere y no consulta con texto vacío', () async {
      final c = ProtocolSuggestionCubit(repo);
      await c.suggest('   ');
      expect(repo.calls, isEmpty);
      await c.suggest('mujer de 58 años, DM2');
      expect(c.state.status, AiRequestStatus.success);
      expect(c.state.data!.suggestions, hasLength(3));
    });

    test('error con detail', () async {
      repo.error = const AiException(503, 'La IA está desactivada.');
      final c = ProtocolSuggestionCubit(repo);
      await c.suggest('caso clínico');
      expect(c.state.status, AiRequestStatus.failure);
      expect(c.state.error!.detail, 'La IA está desactivada.');
    });
  });

  group('DocumentExtractionCubit', () {
    test('lee un JPEG', () async {
      final c = DocumentExtractionCubit(repo);
      await c.extract(bytes: Uint8List(10), filename: 'foto.JPG');
      expect(c.state.status, AiRequestStatus.success);
      expect(c.state.data!.notesText, contains('HbA1c'));
    });

    test('rechaza más de 8 MB sin llamar al backend', () async {
      final c = DocumentExtractionCubit(repo);
      await c.extract(
        bytes: Uint8List(DocumentExtractionCubit.maxBytes + 1),
        filename: 'a.pdf',
      );
      expect(c.state.error!.statusCode, DocumentExtractionCubit.tooLargeCode);
      expect(repo.calls, isEmpty);
    });

    test('rechaza formatos no admitidos', () async {
      final c = DocumentExtractionCubit(repo);
      await c.extract(bytes: Uint8List(1), filename: 'a.heic');
      expect(
        c.state.error!.statusCode,
        DocumentExtractionCubit.unsupportedCode,
      );
    });
  });

  group('DictationCubit', () {
    test('transcribe en vivo y propone campos al terminar', () async {
      final speech = FakeSpeechService(
        script: 'mujer de 58 años con diabetes',
        wordInterval: const Duration(milliseconds: 1),
      );
      final c = DictationCubit(repo, speech);
      final phases = <DictationPhase>[];
      final sub = c.stream.listen((s) => phases.add(s.phase));
      await c.start();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(c.state.phase, DictationPhase.proposal);
      expect(c.state.transcript, 'mujer de 58 años con diabetes');
      expect(c.state.fields!.age, 58);
      expect(
        phases,
        containsAllInOrder([
          DictationPhase.listening,
          DictationPhase.parsing,
          DictationPhase.proposal,
        ]),
      );
      await sub.cancel();
      await c.close();
    });

    test('"Listo" detiene la escucha y procesa lo dictado', () async {
      final speech = FakeSpeechService(
        script: 'paciente con hipertensión',
        wordInterval: const Duration(milliseconds: 1),
        autoFinish: false,
      );
      final c = DictationCubit(repo, speech);
      await c.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(c.state.phase, DictationPhase.listening);
      await c.stop();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(c.state.phase, DictationPhase.proposal);
      expect(repo.calls, contains('dictation'));
      await c.close();
    });

    test('dictado demasiado corto: no llama a la IA', () async {
      final c = DictationCubit(
        repo,
        FakeSpeechService(
          script: 'sí',
          wordInterval: const Duration(milliseconds: 1),
        ),
      );
      await c.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(c.state.phase, DictationPhase.empty);
      expect(repo.calls, isEmpty);
    });

    test('sin micrófono: no disponible', () async {
      final c = DictationCubit(repo, FakeSpeechService(available: false));
      await c.start();
      expect(c.state.phase, DictationPhase.unavailable);
    });

    test('solo transcripción (IA-03): no llama a parse-dictation', () async {
      final c = DictationCubit(
        repo,
        FakeSpeechService(
          script: 'caso clínico',
          wordInterval: const Duration(milliseconds: 1),
        ),
        parse: false,
      );
      await c.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(c.state.phase, DictationPhase.idle);
      expect(c.state.transcript, 'caso clínico');
      expect(repo.calls, isEmpty);
    });

    test('error de la IA al ordenar el dictado', () async {
      repo.error = FakeAiRepository.errorDailyLimit;
      final c = DictationCubit(repo, FakeSpeechService());
      await c.parseTranscript('texto');
      expect(c.state.phase, DictationPhase.failure);
      expect(c.state.error!.statusCode, 429);
    });
  });

  group('RejectionFeedbackCubit', () {
    test('con rechazos', () async {
      final c = RejectionFeedbackCubit(repo);
      await c.load();
      expect(c.state.data!.total, 4);
      expect(c.state.data!.categories, hasLength(3));
    });

    test('sin rechazos', () async {
      repo.noRejections = true;
      final c = RejectionFeedbackCubit(repo);
      await c.load();
      expect(c.state.data!.total, 0);
      expect(c.state.data!.categories, isEmpty);
    });
  });

  group('AssistantCubit', () {
    test('conversa y manda como máximo 6 mensajes de historia', () async {
      final c = AssistantCubit(repo, protocolId: 'p1');
      for (var i = 0; i < 5; i++) {
        await c.ask('pregunta $i');
      }
      expect(c.state.messages, hasLength(10));
      expect(repo.lastProtocolId, 'p1');
      // En la 5.ª pregunta había 8 mensajes previos: viajan los últimos 6.
      expect(repo.lastHistory, hasLength(6));
      expect(repo.lastHistory!.last.role, 'assistant');
      expect(repo.lastHistory!.first.content, 'pregunta 1');
      expect(c.state.messages.last.sources, isNotEmpty);
      expect(c.state.messages.last.followUps, isNotEmpty);
    });

    test('error y reintento sin duplicar la pregunta', () async {
      final c = AssistantCubit(repo);
      repo.error = const AiException(502, 'La IA no respondió.');
      await c.ask('hola');
      expect(c.state.error!.detail, 'La IA no respondió.');
      expect(c.state.messages, hasLength(1));
      repo.error = null;
      await c.retry();
      expect(c.state.error, isNull);
      expect(c.state.messages.map((m) => m.role), ['user', 'assistant']);
      expect(repo.lastHistory, isEmpty);
    });
  });
}
