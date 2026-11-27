import 'dart:typed_data';

import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/data/repositories/fake_ai_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/document_extraction_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/eligibility_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/rejection_feedback_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/screens/protocol_assistant_screen.dart';
import 'package:clinexa_derivant_app/presentation/ai/screens/protocol_suggestion_screen.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_home_entry.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/dictation_sheet.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/document_reader_sheet.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/eligibility_panel.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/rejection_feedback_card.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ai_test_app.dart';

class _FakePatients implements PatientRepository {
  @override
  Future<PatientModel> create(PatientModel patient) async => PatientModel(
    id: 'pac-1',
    firstName: patient.firstName,
    lastName: patient.lastName,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUpAiWidgetTests();
  late FakeAiRepository repo;

  setUp(
    () => repo = FakeAiRepository(delay: const Duration(milliseconds: 300)),
  );

  Future<void> phone(WidgetTester t) async {
    t.view.physicalSize = const Size(393 * 3, 852 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  group('AiGate', () {
    testWidgets('oculta la IA si está desactivada', (t) async {
      repo.enabled = false;
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: const Scaffold(body: AiGate(child: AiHomeEntry())),
        ),
      );
      await settle(t, 500);
      expect(find.byType(AiHomeEntry), findsNothing);
    });

    testWidgets('muestra la entrada de Inicio si está activa', (t) async {
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: const Scaffold(body: AiGate(child: AiHomeEntry())),
        ),
      );
      await settle(t, 500);
      expect(
        find.text('Describe tu caso y te sugiero protocolos'),
        findsOneWidget,
      );
    });
  });

  group('IA-03 · Sugerencia de protocolos', () {
    testWidgets('espera con ClxAiThinking y muestra las sugerencias', (
      t,
    ) async {
      await phone(t);
      await t.pumpWidget(
        aiTestApp(repo: repo, child: const ProtocolSuggestionScreen()),
      );
      await settle(t, 300);
      await t.enterText(
        find.byType(EditableText),
        'mujer de 58 años, DM2, HbA1c 8.2',
      );
      await t.pump();
      await t.tap(find.byKey(const Key('ai_suggest_submit')));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(ClxAiThinking), findsOneWidget);
      await settle(t, 1500);
      expect(find.byKey(const Key('ai_suggest_results')), findsOneWidget);
      expect(find.text('Estudio DM2-OPT'), findsOneWidget);
      expect(find.byType(ClxAiScore), findsNWidgets(3));
    });

    testWidgets('muestra el detail del error tal cual', (t) async {
      await phone(t);
      repo.error = FakeAiRepository.errorDailyLimit;
      await t.pumpWidget(
        aiTestApp(repo: repo, child: const ProtocolSuggestionScreen()),
      );
      await settle(t, 300);
      await t.enterText(find.byType(EditableText), 'caso clínico');
      await t.pump();
      await t.tap(find.byKey(const Key('ai_suggest_submit')));
      await settle(t, 800);
      expect(find.textContaining('límite diario'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('el dictado llena la descripción', (t) async {
      await phone(t);
      await t.pumpWidget(
        aiTestApp(repo: repo, child: const ProtocolSuggestionScreen()),
      );
      await settle(t, 300);
      await t.tap(find.byKey(const Key('ai_suggest_dictate')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));
      expect(find.byType(ClxAiVoiceWave), findsOneWidget);
      await settle(t, 4000);
      final field = t.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, contains('diabetes tipo 2'));
      expect(repo.calls, isNot(contains('dictation')));
    });
  });

  group('IA-09 · Asistente', () {
    testWidgets('responde con fuentes y preguntas sugeridas', (t) async {
      await phone(t);
      await t.pumpWidget(
        aiTestApp(repo: repo, child: const ProtocolAssistantScreen()),
      );
      await settle(t, 500);
      await t.tap(find.byKey(const ValueKey('ai_assistant_starter_0')));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('ai_assistant_thinking')), findsOneWidget);
      await settle(t, 4000);
      expect(find.text('FUENTES'), findsOneWidget);
      expect(find.textContaining('Criterio 4'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ai_assistant_followup_0')),
        findsOneWidget,
      );
      expect(find.byType(ClxAiDisclaimer), findsWidgets);
    });

    testWidgets('desde un protocolo manda su protocol_id', (t) async {
      await phone(t);
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: const ProtocolAssistantScreen(
            args: AssistantArgs(protocolId: 'p7', protocolName: 'Estudio X'),
          ),
        ),
      );
      await settle(t, 500);
      expect(find.textContaining('Estudio X'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('ai_assistant_starter_0')));
      await settle(t, 1000);
      expect(repo.lastProtocolId, 'p7');
    });
  });

  group('IA-07 · Consejos', () {
    Widget card() => Scaffold(
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (_) => RejectionFeedbackCubit(repo),
          child: const RejectionFeedbackCard(),
        ),
      ),
    );

    testWidgets('resumen y categorías al expandir', (t) async {
      await phone(t);
      await t.pumpWidget(aiTestApp(repo: repo, child: card()));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('ai_rejections_thinking')), findsOneWidget);
      await settle(t, 1000);
      expect(find.text('Consejos para tus derivaciones'), findsOneWidget);
      expect(find.text('4 rechazos'), findsOneWidget);
      await t.tap(find.byKey(const Key('ai_rejections_toggle')));
      await settle(t, 800);
      expect(find.text('Faltan estudios de laboratorio'), findsOneWidget);
    });

    testWidgets('sin rechazos: mensaje positivo', (t) async {
      repo.noRejections = true;
      await t.pumpWidget(aiTestApp(repo: repo, child: card()));
      await settle(t, 1000);
      expect(find.byKey(const Key('ai_rejections_none')), findsOneWidget);
      expect(find.text('¡Vas muy bien!'), findsOneWidget);
    });
  });

  group('IA-02 · Pre-evaluación', () {
    testWidgets('evalúa, advierte sin bloquear y deja corregir', (t) async {
      await phone(t);
      final reg = PatientRegistrationCubit(_FakePatients(), protocolId: 'p1');
      final elig = EligibilityCubit(repo, protocolId: 'p1');
      reg.notesController.text = 'DM2 desde 2019, HbA1c 8.2 %';
      reg.setGender('Female');
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: elig),
              BlocProvider.value(value: reg),
            ],
            child: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: EligibilityPanel(),
              ),
            ),
          ),
        ),
      );
      await settle(t, 300);
      expect(find.text('Femenino'), findsOneWidget);
      await t.ensureVisible(find.byKey(const Key('ai_eligibility_evaluate')));
      await t.tap(find.byKey(const Key('ai_eligibility_evaluate')));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('ai_eligibility_thinking')), findsOneWidget);
      await settle(t, 1500);
      expect(find.byKey(const Key('ai_eligibility_result')), findsOneWidget);
      expect(
        find.byKey(const Key('ai_eligibility_fails_warning')),
        findsOneWidget,
      );

      final fix = find.byKey(const ValueKey('ai_eligibility_5_meets'));
      await t.ensureVisible(fix);
      await t.tap(fix);
      await settle(t, 500);
      expect(
        find.byKey(const Key('ai_eligibility_fails_warning')),
        findsNothing,
      );
      expect(find.text('Corregido por ti'), findsOneWidget);

      // Al registrar, se vincula con las correcciones.
      repo.delay = Duration.zero;
      expect(await elig.attach('pac-1'), isTrue);
      expect(repo.lastReviewed![5], EligibilityStatus.meets);
    });

    testWidgets('sin datos del caso no llama a la IA', (t) async {
      final reg = PatientRegistrationCubit(_FakePatients(), protocolId: 'p1');
      final elig = EligibilityCubit(repo, protocolId: 'p1');
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: elig),
              BlocProvider.value(value: reg),
            ],
            child: const Scaffold(
              body: SingleChildScrollView(child: EligibilityPanel()),
            ),
          ),
        ),
      );
      await settle(t, 300);
      await t.ensureVisible(find.byKey(const Key('ai_eligibility_evaluate')));
      await t.tap(find.byKey(const Key('ai_eligibility_evaluate')));
      await settle(t, 500);
      expect(repo.calls, isNot(contains('eligibility')));
    });
  });

  group('IA-05 · Dictado', () {
    testWidgets('propone campos y devuelve solo lo marcado', (t) async {
      await phone(t);
      DictationFields? result;
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    result = await showDictationSheet(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('abrir'));
      await settle(t, 500);
      expect(find.text('Te escucho…'), findsOneWidget);
      await settle(t, 4000);
      expect(find.text('Revisa lo que entendió la IA'), findsOneWidget);
      // Desmarca la edad.
      await t.tap(find.byKey(const ValueKey('ai_dictation_field_age')));
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('ai_dictation_apply')));
      await t.tap(find.byKey(const Key('ai_dictation_apply')));
      await settle(t, 600);
      expect(result, isNotNull);
      expect(result!.age, isNull);
      expect(result!.sex, 'female');
      expect(result!.pathologies, contains('Diabetes tipo 2'));
    });
  });

  group('IA-04 · Lectura de estudios', () {
    testWidgets('muestra los valores y agrega notes_text', (t) async {
      await phone(t);
      final cubit = DocumentExtractionCubit(repo);
      String? result;
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await ClxSheet.show<String>(
                  context,
                  title: 'Leer un estudio',
                  child: BlocProvider.value(
                    value: cubit,
                    child: const DocumentReaderBody(),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('abrir'));
      await settle(t, 500);
      expect(find.text('Tomar foto'), findsOneWidget);
      expect(find.textContaining('La imagen no se guarda'), findsOneWidget);
      cubit.extract(bytes: Uint8List(4), filename: 'estudio.jpg');
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(ClxAiThinking), findsOneWidget);
      await settle(t, 1200);
      expect(find.text('HbA1c'), findsOneWidget);
      expect(find.text('10/11/2026'), findsWidgets);
      await t.ensureVisible(find.byKey(const Key('ai_study_add_notes')));
      await t.tap(find.byKey(const Key('ai_study_add_notes')));
      await settle(t, 600);
      expect(result, startsWith('Laboratorio del 10/11/2026'));
    });

    testWidgets('archivo de más de 8 MB: aviso local', (t) async {
      final cubit = DocumentExtractionCubit(repo);
      await t.pumpWidget(
        aiTestApp(
          repo: repo,
          child: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const DocumentReaderBody(),
            ),
          ),
        ),
      );
      await cubit.extract(
        bytes: Uint8List(DocumentExtractionCubit.maxBytes + 1),
        filename: 'a.pdf',
      );
      await settle(t, 500);
      expect(
        find.text('El archivo supera los 8 MB. Elige uno más pequeño.'),
        findsOneWidget,
      );
    });
  });
}
