import 'package:clinexa_derivant_app/domain/user_status_repository.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/home_screen.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/user_status/cubit/user_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SessionCheckScreen extends StatelessWidget {
  static const path = "/session-check";

  final String userId;

  const SessionCheckScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SessionCheckCubit(context.read<UserStatusRepository>())..init(userId),
      child: const SessionCheckView(),
    );
  }
}

class SessionCheckView extends StatelessWidget {
  const SessionCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasNavigated = false; // ⬅️ evita múltiples navegaciones

    return Scaffold(
      body: BlocConsumer<SessionCheckCubit, SessionCheckState>(
        listener: (context, state) async {
          if (state.status == Status.success && state.userStatus != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (hasNavigated) return;
              hasNavigated = true;
              context.go(HomeScreen.path);
              // if (status.profileCompleted) {

              // }
              // else if (status.missingRequiredFields.contains("protocols")) {
              //   hasNavigated = true;
              //   context.go(ProtocolListScreen.path);
              // } else {
              //   // fallback general si agregas otros pasos
              //   hasNavigated = true;
              //   context.go(LoginScreen.path);
              // }
            });
          }
          // Error handling con dialogs
          else if (state.status == Status.error) {
            CustomDialogs.errorDialog(
              context,
              "Error al verificar el estado del usuario",
              onTap: () {
                context.read<AuthCubit>().logout();
                context.go(LoginScreen.path);
              },
            );
          }
        },
        builder: (context, state) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
