import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_status_cubit.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerProvider extends StatelessWidget {
  final Widget child;
  const ManagerProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (context) => AuthCubit(
            context.read<AuthRepository>(),
            context.read<NotificationService>(),
          )..initAuth(),
        ),
        // Disponibilidad de la IA: se consulta al montar la primera
        // función de IA (ver AiGate).
        BlocProvider<AiStatusCubit>(
          create: (context) => AiStatusCubit(context.read<AiRepository>()),
        ),
      ],
      child: child,
    );
  }
}
