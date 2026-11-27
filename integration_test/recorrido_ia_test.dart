// Recorrido visual de las funciones de IA de la app Derivante: espera
// (ClxAiThinking), resultado, error e IA desactivada de cada función.
//
// Usa el repositorio de IA falso (respuestas del contrato), así que no
// necesita que el backend tenga las rutas /ai/app/*. Ejecuta (una vez por
// tema):
//   CLX_CAPTURAS_DIR=../capturas-ia/derivante \
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/recorrido_ia_test.dart \
//     --dart-define=CLX_AI_FAKE=on --dart-define=CLX_THEME=light \
//     --dart-define=CLX_TEST_EMAIL=… --dart-define=CLX_TEST_PASSWORD=… \
//     -d <simulador>
//
// No envía formularios: no crea, edita ni borra datos en dev.

import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/data/repositories/fake_ai_repository.dart';
import 'package:clinexa_derivant_app/data/repositories/notification_repository_impl.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/firebase_options.dart';
import 'package:clinexa_derivant_app/main.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_status_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/document_extraction_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/document_reader_sheet.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/home_screen.dart';
import 'package:clinexa_derivant_app/presentation/patients/patients_screen.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_registration_screen.dart';
import 'package:clinexa_derivant_app/presentation/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _tema = String.fromEnvironment('CLX_THEME', defaultValue: 'light');
const _email = String.fromEnvironment('CLX_TEST_EMAIL');
const _password = String.fromEnvironment('CLX_TEST_PASSWORD');

Future<void> _arrancarApp() async {
  await AppConfig.load();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await SharedPrefsService.instance.init();
  final Api api = await createApiInstance();
  ApiService().setBaseUrl(api.baseUrl);
  final notificationService = NotificationService(
    repository: NotificationRepositoryImpl(api: api),
  );
  runApp(ClinexaApp(api: api, notificationService: notificationService));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final sufijo = _tema == 'dark' ? 'oscuro' : 'claro';

  testWidgets('recorrido de IA ($sufijo)', (t) async {
    Future<void> asentar([int ms = 700]) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    Future<bool> esperar(Finder f, {int segundos = 30}) async {
      final fin = DateTime.now().add(Duration(seconds: segundos));
      while (DateTime.now().isBefore(fin)) {
        await t.pump(const Duration(milliseconds: 200));
        if (f.evaluate().isNotEmpty) return true;
      }
      return false;
    }

    Future<void> foto(String nombre, {int ms = 600}) async {
      await asentar(ms);
      await binding.takeScreenshot('$nombre-$sufijo');
    }

    Future<void> tocar(Finder f, {int ms = 600}) async {
      await t.ensureVisible(f.first);
      await t.pump();
      await t.tap(f.first, warnIfMissed: false);
      await asentar(ms);
    }

    Future<void> verArriba(Finder f, {double alignment = 0.1}) async {
      await Scrollable.ensureVisible(t.element(f.first), alignment: alignment);
      await asentar(400);
    }

    BuildContext ctx() => t.element(find.byType(Scaffold).last);

    void sinTeclado() {
      FocusManager.instance.primaryFocus?.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }

    // ── Arranque e inicio de sesión ──────────────────────────────────────
    await _arrancarApp();
    final inicio = find.byKey(const Key('home_profile_button'));
    final bienvenida = find.byKey(const Key('welcome_login_button'));
    await esperar(
      find.byWidgetPredicate(
        (w) =>
            w.key == const Key('welcome_login_button') ||
            w.key == const Key('home_profile_button'),
      ),
      segundos: 40,
    );
    if (inicio.evaluate().isEmpty) {
      await tocar(bienvenida);
      await t.enterText(
        find.descendant(
          of: find.byKey(const Key('login_email_field')),
          matching: find.byType(EditableText),
        ),
        _email,
      );
      await t.enterText(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(EditableText),
        ),
        _password,
      );
      sinTeclado();
      await asentar(300);
      await t.tap(find.byKey(const Key('login_submit_button')));
      expect(await esperar(inicio, segundos: 60), isTrue);
    }

    final repo = ctx().read<AiRepository>();
    expect(
      repo,
      isA<FakeAiRepository>(),
      reason: 'Falta --dart-define=CLX_AI_FAKE=on',
    );
    final fake = repo as FakeAiRepository;
    fake.delay = const Duration(milliseconds: 2500);

    // ── Inicio (IA-03 y acceso al asistente) ─────────────────────────────
    await esperar(find.byKey(const ValueKey('protocol_card_0')), segundos: 20);
    await esperar(find.byKey(const Key('ai_home_entry')), segundos: 10);
    await foto('ia-inicio', ms: 1200);

    // ── IA-03 · Sugerencia de protocolos ─────────────────────────────────
    await tocar(find.byKey(const Key('ai_home_describe')), ms: 1000);
    await foto('ia-03-sugerir-vacio');
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('ai_suggest_field')),
        matching: find.byType(EditableText),
      ),
      'Mujer de 58 años con diabetes tipo 2, HbA1c 8.2 % en noviembre, '
      'toma metformina 850 mg dos veces al día. Sin eventos cardiovasculares.',
    );
    sinTeclado();
    await asentar(500);
    await tocar(find.byKey(const Key('ai_suggest_submit')), ms: 300);
    await verArriba(
      find.byKey(const Key('ai_suggest_thinking')),
      alignment: 0.5,
    );
    await foto('ia-03-sugerir-pensando', ms: 800);
    await esperar(find.byKey(const Key('ai_suggest_results')));
    await verArriba(find.byKey(const Key('ai_suggest_results')));
    await foto('ia-03-sugerir-resultado', ms: 1200);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await foto('ia-03-sugerir-resultado-2');
    fake.error = FakeAiRepository.errorDailyLimit;
    fake.delay = const Duration(milliseconds: 300);
    await tocar(find.byKey(const Key('ai_suggest_submit')), ms: 1200);
    await verArriba(find.byKey(const Key('ai_error_notice')), alignment: 0.5);
    await foto('ia-03-sugerir-error');
    fake.error = null;
    // Dictado del caso (solo transcribe).
    await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await asentar(400);
    await tocar(find.byKey(const Key('ai_suggest_dictate')), ms: 1800);
    await foto('ia-05-dictar-caso-escuchando', ms: 100);
    await asentar(4500);
    AppRouter.router.pop();
    await asentar(900);

    // ── IA-09 · Asistente ────────────────────────────────────────────────
    fake.delay = const Duration(milliseconds: 2500);
    await tocar(find.byKey(const Key('home_ai_assistant_button')), ms: 1200);
    await foto('ia-09-asistente-inicio');
    await tocar(find.byKey(const ValueKey('ai_assistant_starter_0')), ms: 600);
    await foto('ia-09-asistente-pensando', ms: 600);
    await esperar(find.textContaining('Dos protocolos activos'));
    await foto('ia-09-asistente-escribiendo', ms: 700);
    await asentar(3500);
    await foto('ia-09-asistente-respuesta');
    fake.error = const AiException(
      502,
      'La IA no respondió a tiempo. Inténtalo de nuevo en unos minutos.',
    );
    fake.delay = const Duration(milliseconds: 300);
    await tocar(
      find.byKey(const ValueKey('ai_assistant_followup_0')),
      ms: 1500,
    );
    await foto('ia-09-asistente-error');
    fake.error = null;
    AppRouter.router.pop();
    await asentar(900);

    // ── IA-07 · Consejos en Mis pacientes ────────────────────────────────
    fake.delay = const Duration(milliseconds: 4000);
    AppRouter.router.go(PatientsScreen.path);
    await asentar(1200);
    await foto('ia-07-consejos-pensando', ms: 300);
    await esperar(find.byKey(const Key('ai_rejections_result')));
    await foto('ia-07-consejos-resultado', ms: 1200);
    await tocar(find.byKey(const Key('ai_rejections_toggle')), ms: 900);
    await foto('ia-07-consejos-detalle');
    await t.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await foto('ia-07-consejos-detalle-2');

    fake.delay = const Duration(milliseconds: 300);
    fake.noRejections = true;
    AppRouter.router.go(HomeScreen.path);
    await asentar(800);
    AppRouter.router.go(PatientsScreen.path);
    await esperar(find.byKey(const Key('ai_rejections_none')));
    await foto('ia-07-consejos-sin-rechazos', ms: 1200);
    fake.noRejections = false;
    fake.error = const AiException(
      429,
      'Alcanzaste el tope mensual de IA de Clinexapp. Se renueva el 1 del mes.',
    );
    AppRouter.router.go(HomeScreen.path);
    await asentar(800);
    AppRouter.router.go(PatientsScreen.path);
    await esperar(find.byKey(const Key('ai_rejections_error')));
    await foto('ia-07-consejos-error', ms: 1000);
    fake.error = null;

    // ── Criterios: acceso al asistente con el protocolo ──────────────────
    AppRouter.router.go(HomeScreen.path);
    await esperar(find.byKey(const ValueKey('protocol_card_0')), segundos: 20);
    await asentar(800);
    await tocar(find.byKey(const ValueKey('protocol_card_0')), ms: 1500);
    await foto('ia-09-criterios-boton-asistente');
    await tocar(
      find.byKey(const Key('criteria_ai_assistant_button')),
      ms: 1200,
    );
    await foto('ia-09-asistente-protocolo');
    AppRouter.router.pop();
    await asentar(800);
    AppRouter.router.pop();
    await asentar(800);

    // ── Formulario del paciente: IA-05, IA-04 e IA-02 ────────────────────
    AppRouter.router.push(PatientRegistrationScreen.path, extra: 'demo-p1');
    await asentar(1500);
    await verArriba(find.byKey(const Key('ai_dictate_button')), alignment: 0.3);
    await foto('ia-paciente-herramientas');

    // IA-05 · Dictado
    fake.delay = const Duration(milliseconds: 2500);
    await tocar(find.byKey(const Key('ai_dictate_button')), ms: 2200);
    await foto('ia-05-dictado-escuchando', ms: 100);
    await esperar(find.text('Ordenando lo que dictaste…'), segundos: 10);
    await foto('ia-05-dictado-pensando', ms: 500);
    await esperar(find.byKey(const Key('ai_dictation_apply')));
    await foto('ia-05-dictado-propuesta', ms: 1000);
    await tocar(find.byKey(const Key('ai_dictation_apply')), ms: 1200);
    await verArriba(
      find.byKey(const Key('patient_notes_field')),
      alignment: 0.2,
    );
    await foto('ia-05-dictado-aplicado');

    fake.error = FakeAiRepository.errorDailyLimit;
    fake.delay = const Duration(milliseconds: 300);
    await tocar(find.byKey(const Key('ai_dictate_button')), ms: 2000);
    await esperar(find.byKey(const Key('ai_error_notice')), segundos: 10);
    await foto('ia-05-dictado-error');
    Navigator.of(ctx(), rootNavigator: true).pop();
    await asentar(800);
    fake.error = null;

    // IA-04 · Lectura de estudios (la imagen se simula: el simulador no
    // tiene cámara).
    fake.delay = const Duration(milliseconds: 2500);
    await tocar(find.byKey(const Key('ai_read_study_button')), ms: 1000);
    await foto('ia-04-estudio-elegir');
    final lector = t
        .element(find.byType(DocumentReaderBody))
        .read<DocumentExtractionCubit>();
    lector.extract(bytes: Uint8List(2048), filename: 'estudio.jpg');
    await foto('ia-04-estudio-pensando', ms: 800);
    await esperar(find.byKey(const Key('ai_study_add_notes')));
    await foto('ia-04-estudio-resultado', ms: 1200);
    fake.error = const AiException(
      400,
      'No pudimos leer el estudio. Prueba con una foto más nítida y con buena luz.',
    );
    fake.delay = const Duration(milliseconds: 300);
    await tocar(find.text('Leer otro estudio'), ms: 500);
    lector.extract(bytes: Uint8List(2048), filename: 'estudio.jpg');
    await foto('ia-04-estudio-error', ms: 1200);
    fake.error = null;
    fake.delay = const Duration(milliseconds: 300);
    lector.extract(bytes: Uint8List(2048), filename: 'estudio.jpg');
    await esperar(find.byKey(const Key('ai_study_add_notes')));
    await tocar(find.byKey(const Key('ai_study_add_notes')), ms: 1200);
    await verArriba(
      find.byKey(const Key('patient_notes_field')),
      alignment: 0.2,
    );
    await foto('ia-04-estudio-agregado');

    // IA-02 · Pre-evaluación
    fake.delay = const Duration(milliseconds: 3000);
    await verArriba(find.byKey(const Key('ai_eligibility_panel')));
    await foto('ia-02-elegibilidad-inicio');
    await tocar(find.byKey(const Key('ai_eligibility_evaluate')), ms: 400);
    await verArriba(
      find.byKey(const Key('ai_eligibility_thinking')),
      alignment: 0.6,
    );
    await foto('ia-02-elegibilidad-pensando', ms: 600);
    await esperar(find.byKey(const Key('ai_eligibility_result')));
    await verArriba(find.byKey(const Key('ai_eligibility_result')));
    await foto('ia-02-elegibilidad-resultado', ms: 1400);
    await verArriba(find.byKey(const ValueKey('ai_eligibility_item_3')));
    await foto('ia-02-elegibilidad-criterios');
    await tocar(find.byKey(const ValueKey('ai_eligibility_5_meets')));
    await tocar(find.byKey(const ValueKey('ai_eligibility_4_meets')));
    await verArriba(find.byKey(const ValueKey('ai_eligibility_item_4')));
    await foto('ia-02-elegibilidad-corregida');
    fake.error = const AiException(
      503,
      'La IA está desactivada temporalmente. Puedes continuar sin ella.',
    );
    fake.delay = const Duration(milliseconds: 300);
    await verArriba(find.byKey(const Key('ai_eligibility_panel')));
    await tocar(find.byKey(const Key('ai_eligibility_evaluate')), ms: 1200);
    await verArriba(find.byKey(const Key('ai_error_notice')), alignment: 0.4);
    await foto('ia-02-elegibilidad-error');
    fake.error = null;
    AppRouter.router.pop();
    await asentar(900);

    // ── IA desactivada: todo vuelve a verse como antes ───────────────────
    fake.enabled = false;
    await ctx().read<AiStatusCubit>().ensureLoaded(refresh: true);
    AppRouter.router.go(HomeScreen.path);
    await esperar(find.byKey(const ValueKey('protocol_card_0')), segundos: 20);
    await foto('ia-desactivada-inicio', ms: 1200);
    AppRouter.router.go(PatientsScreen.path);
    await asentar(2500);
    await foto('ia-desactivada-pacientes');
    AppRouter.router.push(PatientRegistrationScreen.path, extra: 'demo-p1');
    await asentar(1500);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await foto('ia-desactivada-paciente-notas');
    AppRouter.router.pop();
    await asentar(600);
    fake.enabled = true;
    await ctx().read<AiStatusCubit>().ensureLoaded(refresh: true);
    AppRouter.router.go(HomeScreen.path);
    await asentar(800);
  });
}
