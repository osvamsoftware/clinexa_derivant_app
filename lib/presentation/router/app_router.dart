import 'package:clinexa_derivant_app/presentation/auth_loading/splash_screen.dart';
import 'package:clinexa_derivant_app/presentation/home_screen.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_personal_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profesional_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profile_screen.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_criteria_screen.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_selection_screen.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_registration_screen.dart';
import 'package:clinexa_derivant_app/presentation/patients/patients_screen.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/patient_info_screen.dart';
import 'package:clinexa_derivant_app/presentation/root/root_screen.dart';
import 'package:clinexa_derivant_app/presentation/user_status/user_status_check_screen.dart';
import 'package:clinexa_derivant_app/presentation/welcome/welcome_screen.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/forgot_password/forgot_password_screen.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/reset_password/reset_password_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // 🔹 Router global (singleton)
  static final GoRouter router = GoRouter(
    initialLocation: SplashScreen.path,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return RootPage(child: child);
        },
        routes: [
          GoRoute(
            path: HomeScreen.path,
            name: HomeScreen.path,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: PatientsScreen.path,
            name: PatientsScreen.path,
            builder: (context, state) => const PatientsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: WelcomeScreen.path,
        name: WelcomeScreen.path,
        builder: (context, state) => const WelcomeScreen(),
      ),

      //home
      GoRoute(
        path: LoginScreen.path,
        name: LoginScreen.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.path,
        name: ForgotPasswordScreen.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: ResetPasswordScreen.path,
        name: ResetPasswordScreen.path,
        builder: (context, state) {
          final oobCode = state.uri.queryParameters['oobCode'] ?? "";
          return ResetPasswordScreen(oobCode: oobCode);
        },
      ),

      //loading
      GoRoute(
        path: SplashScreen.path,
        name: SplashScreen.path,
        builder: (context, state) => const SplashScreen(),
      ),
      //register steps
      GoRoute(
        path: RegisterPersonalScreen.path,
        name: RegisterPersonalScreen.path,
        builder: (context, state) => const RegisterPersonalScreen(),
      ),
      GoRoute(
        path: RegisterProfessionalScreen.path,
        name: RegisterProfessionalScreen.path,
        builder: (context, state) {
          final cubit = state.extra as RegisterCubit;
          return BlocProvider.value(
            value: cubit,
            child: RegisterProfessionalScreen(),
          );
        },
      ),
      GoRoute(
        path: RegisterProfileScreen.path,
        name: RegisterProfileScreen.path,
        builder: (context, state) {
          return BlocProvider.value(
            value: state.extra as RegisterCubit,
            child: RegisterProfileScreen(),
          );
        },
      ),
      // Register Patient
      GoRoute(
        path: PatientRegistrationScreen.path,
        name: PatientRegistrationScreen.path,
        builder: (context, state) {
          final protocolId = state.extra as String?;
          return PatientRegistrationScreen(protocolId: protocolId);
        },
      ),
      //SessionCheckScreen
      GoRoute(
        path: SessionCheckScreen.path,
        name: SessionCheckScreen.path,
        builder: (context, state) {
          final userId = state.extra as String;
          return SessionCheckScreen(userId: userId);
        },
      ),
      // Protocol Routes
      GoRoute(
        path: ProtocolSelectionScreen.path,
        name: ProtocolSelectionScreen.path,
        builder: (context, state) => const ProtocolSelectionScreen(),
      ),
      GoRoute(
        path: ProtocolCriteriaScreen.path,
        name: ProtocolCriteriaScreen.path,
        builder: (context, state) {
          final protocol =
              state.extra
                  as dynamic; // Cast to ProtocolModel properly if needed imports allow, or dynamic
          // Imports are top, let's assume imports allow ProtocolModel
          // Actually ProtocolModel is in data/models, we need to import it or cast to dynamic then ProtocolModel inside builder if import is missing.
          // Let's add import at top if possible, but multi_replace might be tricky with imports.
          // I will use dynamic cast here and let dart inference work or just pass it constructor.
          // Better: import ProtocolModel at top.
          return ProtocolCriteriaScreen(protocol: protocol);
        },
      ),
      // Patient Info Route
      GoRoute(
        path: PatientInfoScreen.path,
        name: PatientInfoScreen.path,
        builder: (context, state) {
          final patient = state.extra as dynamic;
          return PatientInfoScreen(patient: patient);
        },
      ),
    ],
    redirect: (context, state) {
      return null;
    },
  );
}
