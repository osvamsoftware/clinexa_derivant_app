// Recorrido visual de la app Derivante: inicia sesión y pasa por todas las
// pantallas alcanzables, guardando una captura de cada una.
//
// Ejecuta (una vez por tema):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/recorrido_capturas_test.dart \
//     --dart-define=CLX_THEME=light -d <simulador>
//   (y luego con CLX_THEME=dark)
//
// Reglas: la base de datos de desarrollo es compartida, así que el recorrido
// NO envía formularios que creen, editen o borren datos. Solo navega, abre
// detalles y muestra validaciones locales.
//
// Credenciales: CLX_TEST_EMAIL y CLX_TEST_PASSWORD (--dart-define).
import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/data/repositories/notification_repository_impl.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/firebase_options.dart';
import 'package:clinexa_derivant_app/main.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/contact/contact_protocol_screen.dart';
import 'package:clinexa_derivant_app/presentation/login/wrong_role_screen.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/home_screen.dart';
import 'package:clinexa_derivant_app/presentation/phone_verification/cubit/phone_verification_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profesional_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profile_screen.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_registration_screen.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_verification_screen.dart';
import 'package:clinexa_derivant_app/presentation/router/app_router.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/welcome/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _tema = String.fromEnvironment('CLX_THEME', defaultValue: 'light');
// Credenciales de la cuenta de prueba: se pasan con --dart-define
// (CLX_TEST_EMAIL y CLX_TEST_PASSWORD) para no dejarlas en el repo.
const _email = String.fromEnvironment('CLX_TEST_EMAIL');
const _password = String.fromEnvironment('CLX_TEST_PASSWORD');

/// Arranca la app igual que `main()`, salvo el permiso de notificaciones:
/// en el simulador la alerta nativa bloquea el arranque hasta que alguien
/// la acepta a mano.
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
  final omitidas = <String>[];

  testWidgets('recorrido de capturas ($sufijo)', (t) async {
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

    Future<void> foto(String nombre) async {
      await asentar(900);
      await binding.takeScreenshot('$nombre-$sufijo');
    }

    Future<void> tocar(Finder f, {int ms = 900}) async {
      await t.ensureVisible(f.first);
      await t.pump();
      await t.tap(f.first, warnIfMissed: false);
      await asentar(ms);
    }

    Future<void> desplazar([double dy = -650]) async {
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isEmpty) return;
      await t.drag(scrollables.first, Offset(0, dy), warnIfMissed: false);
      await asentar(600);
    }

    BuildContext ctx() => t.element(find.byType(Scaffold).last);

    Future<void> volver() async {
      AppRouter.router.pop();
      await asentar(900);
    }

    Finder enDialogo(String texto) =>
        find.descendant(of: find.byType(Dialog), matching: find.text(texto));

    // ── Arranque ─────────────────────────────────────────────────────────
    await _arrancarApp();
    await asentar(500);
    await binding.takeScreenshot('splash-$sufijo');

    final bienvenida = find.byKey(const Key('welcome_login_button'));
    final inicio = find.byKey(const Key('home_profile_button'));
    await esperar(
      find.byWidgetPredicate(
        (w) =>
            w.key == const Key('welcome_login_button') ||
            w.key == const Key('home_profile_button'),
      ),
      segundos: 40,
    );

    // Si quedó una sesión abierta de una corrida anterior, se cierra.
    if (inicio.evaluate().isNotEmpty) {
      ctx().read<AuthCubit>().logout();
      AppRouter.router.go(WelcomeScreen.path);
      await esperar(bienvenida);
    }

    // ── Pantallas públicas ───────────────────────────────────────────────
    await foto('bienvenida');

    await tocar(find.byKey(const Key('welcome_signup_button')));
    await foto('registro-1-datos-personales');
    await tocar(find.text('Continuar'));
    await foto('registro-1-validaciones');
    await volver();

    final authRepo = ctx().read<AuthRepository>();
    AppRouter.router.push(
      RegisterProfessionalScreen.path,
      extra: RegisterCubit(authRepo),
    );
    await asentar(1200);
    await foto('registro-2-datos-profesionales');
    await tocar(find.text('Selecciona una opción'));
    await foto('registro-2-tipo-matricula');
    if (find.text('Matrícula provincial').evaluate().isNotEmpty) {
      await tocar(find.text('Matrícula provincial').last);
    }
    await desplazar();
    await tocar(find.text('Continuar'));
    await foto('registro-2-validaciones');
    await volver();

    AppRouter.router.push(
      RegisterProfileScreen.path,
      extra: RegisterCubit(authRepo),
    );
    await asentar(1200);
    await foto('registro-3-terminos');
    await tocar(find.byKey(const Key('register_terms_checkbox')));
    await foto('registro-3-terminos-aceptados');
    await volver();

    await tocar(bienvenida);
    await foto('login');
    await tocar(find.byKey(const Key('login_submit_button')));
    await foto('login-validaciones');

    await tocar(find.byKey(const Key('login_forgot_button')));
    await foto('recuperar-contrasena');
    await volver();

    AppRouter.router.push('/reset-password?oobCode=demo');
    await asentar(1200);
    await foto('restablecer-contrasena');
    await volver();

    Navigator.of(ctx(), rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const WrongRoleScreen(),
      ),
    );
    await asentar(1200);
    await foto('app-equivocada');
    Navigator.of(ctx(), rootNavigator: true).pop();
    await asentar();

    // Diálogos del sistema (sin llamadas al servidor)
    CustomDialogs.errorDialog(
      ctx(),
      'El correo o la contraseña no son correctos.',
    );
    await foto('dialogo-error');
    await tocar(enDialogo('Entendido'));
    CustomDialogs.loadingDialog(ctx());
    await foto('dialogo-cargando');
    Navigator.of(ctx(), rootNavigator: true).pop();
    await asentar();

    // ── Iniciar sesión ───────────────────────────────────────────────────
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
    await asentar(300);
    FocusManager.instance.primaryFocus?.unfocus();
    await asentar(300);
    await foto('login-completo');
    await t.tap(find.byKey(const Key('login_submit_button')));
    await asentar(500);
    await foto('login-cargando');

    expect(
      await esperar(inicio, segundos: 60),
      isTrue,
      reason: 'No se llegó a Inicio tras iniciar sesión',
    );

    // ── Inicio: protocolos ───────────────────────────────────────────────
    await esperar(find.byKey(const ValueKey('protocol_card_0')), segundos: 20);
    await foto('inicio');
    // ── Derivación: criterios, datos, firma y verificación ───────────────
    final tarjeta = find.byKey(const ValueKey('protocol_card_0'));
    if (tarjeta.evaluate().isNotEmpty) {
      await tocar(tarjeta, ms: 1500);
      await foto('derivacion-1-criterios');
      await tocar(find.byKey(const Key('criteria_next_button')));
      if (find.text('Entendido').evaluate().isNotEmpty) {
        await foto('derivacion-1-criterios-faltantes');
        await tocar(find.text('Entendido'));
      }
      await tocar(find.byKey(const Key('show_all_criteria_button')));
      await foto('derivacion-1-todos-los-criterios');
      Navigator.of(ctx(), rootNavigator: true).pop();
      await asentar();

      // Marca todos los criterios de cada paso y avanza (no envía nada).
      for (var paso = 0; paso < 12; paso++) {
        if (find.byType(PatientRegistrationView).evaluate().isNotEmpty) break;
        // Vuelve arriba: la lista conserva el desplazamiento entre pasos.
        await desplazar(4000);
        for (var i = 0; i < 20; i++) {
          final c = find.byKey(ValueKey('criterion_$i'));
          if (c.evaluate().isEmpty) break;
          await Scrollable.ensureVisible(t.element(c), alignment: 0.3);
          await t.pump();
          await t.tap(c, warnIfMissed: false);
          await asentar(200);
        }
        if (paso == 0) await foto('derivacion-1-criterios-marcados');
        await tocar(find.byKey(const Key('criteria_next_button')), ms: 1200);
      }

      if (find.byType(PatientRegistrationView).evaluate().isNotEmpty) {
        await foto('derivacion-2-datos-paciente');
        await tocar(find.byKey(const Key('patient_registration_submit')));
        await foto('derivacion-2-validaciones');
        await desplazar(-700);
        await foto('derivacion-2-datos-paciente-contacto');
        await desplazar(-900);
        await foto('derivacion-2-datos-paciente-notas');

        final regCubit = t
            .element(find.byType(PatientRegistrationView))
            .read<PatientRegistrationCubit>();
        AppRouter.router.push('/patient-signature', extra: regCubit);
        await asentar(1200);
        await foto('derivacion-3-firma');
        AppRouter.router.push('/patient-verification', extra: regCubit);
        await asentar(1500);
        await foto('derivacion-4-verificacion');
        // Estado "código enviado" sin enviar nada por WhatsApp.
        final verif = t
            .element(find.byType(PatientVerificationScreenView))
            .read<PhoneVerificationCubit>();
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        verif.emit(
          verif.state.copyWith(
            status: PhoneVerificationStatus.codeSent,
            resendTimer: 45,
            canResendCode: false,
          ),
        );
        await asentar();
        await foto('derivacion-4-codigo');
      } else {
        omitidas.add('derivación (no se completaron los criterios)');
      }
      AppRouter.router.go(HomeScreen.path);
      await esperar(inicio);
      await asentar(1500);
    } else {
      omitidas.add('derivación (no hay protocolos)');
    }

    await tocar(find.text('Por nombre'));
    await foto('inicio-buscar-por-nombre');
    await tocar(find.text('Por especialidad'));
    await tocar(find.byKey(const Key('protocol_specialty_dropdown')));
    await foto('inicio-filtro-especialidad');
    // Cierra el menú sin elegir.
    await t.tapAt(t.getCenter(find.text('Protocolos disponibles')));
    await asentar(1200);

    // ── Notificaciones ───────────────────────────────────────────────────
    await tocar(find.byKey(const Key('home_notifications_button')), ms: 1500);
    await esperar(
      find.byKey(const ValueKey('notification_card_0')),
      segundos: 15,
    );
    await foto('notificaciones');
    final notif = find.byKey(const ValueKey('notification_card_0'));
    if (notif.evaluate().isNotEmpty) {
      await tocar(notif, ms: 1200);
      await foto('notificacion-detalle');
      await volver();
    } else {
      omitidas.add('detalle de notificación (no hay notificaciones)');
    }
    await volver();

    // ── Pacientes ────────────────────────────────────────────────────────
    await tocar(find.text('Pacientes'), ms: 1500);
    await esperar(find.byKey(const ValueKey('patient_card_0')), segundos: 20);
    await foto('mis-pacientes');
    final paciente = find.byKey(const ValueKey('patient_card_0'));
    if (paciente.evaluate().isNotEmpty) {
      await tocar(paciente, ms: 2000);
      await foto('paciente-detalle');
      await desplazar(-700);
      await foto('paciente-detalle-2');
      await desplazar(-900);
      await foto('paciente-detalle-3');
      final estado = find.byKey(const Key('patient_toggle_status'));
      if (estado.evaluate().isNotEmpty) {
        await tocar(estado);
        await foto('paciente-confirmar-estado');
        await tocar(enDialogo('Cancelar'));
      }
      await volver();
    } else {
      omitidas.add('detalle de paciente (no hay pacientes)');
    }
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('patients_search_field')),
        matching: find.byType(EditableText),
      ),
      'zzzz-sin-resultados',
    );
    await asentar(1500);
    FocusManager.instance.primaryFocus?.unfocus();
    await foto('mis-pacientes-sin-resultados');

    // ── Contacto (ruta sin acceso desde el menú) ─────────────────────────
    AppRouter.router.push(ContactProtocolScreen.path);
    await asentar(1200);
    await foto('contacto-protocolos');
    await volver();

    // ── Perfil y cierre de sesión ────────────────────────────────────────
    await tocar(find.text('Inicio'), ms: 1200);
    await tocar(find.byKey(const Key('home_profile_button')), ms: 1500);
    await foto('perfil');
    await desplazar(-900);
    await foto('perfil-2');
    await tocar(find.byKey(const Key('profile_logout_tile')));
    await foto('perfil-cerrar-sesion');
    await tocar(enDialogo('Cerrar sesión'), ms: 2500);
    await foto('login-tras-cerrar-sesion');

    if (omitidas.isNotEmpty) {
      debugPrint('PANTALLAS OMITIDAS: ${omitidas.join('; ')}');
    }
  });
}
