import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/services/env.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/data/repositories/payment_movement_repository_impl.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/domain/payment_movement_repository.dart';
import 'package:clinexa_derivant_app/domain/user_repository.dart';
import 'package:clinexa_derivant_app/domain/user_status_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart'; // Import
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/presentation/pathology/pathology_repository.dart';
import 'package:clinexa_derivant_app/domain/repositories/notification_repository.dart';
import 'package:clinexa_derivant_app/data/repositories/notification_repository_impl.dart';
import 'package:clinexa_derivant_app/core/services/speech_service.dart';
import 'package:clinexa_derivant_app/data/repositories/fake_ai_repository.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Repositorio de IA falso (solo en debug): `--dart-define=CLX_AI_FAKE=on`.
/// Responde como el contrato sin llamar al backend y simula el dictado.
/// Sirve mientras el backend no tenga las rutas `/ai/app/*` y para las
/// capturas. En release se ignora.
const _aiFake = String.fromEnvironment('CLX_AI_FAKE');
bool get useFakeAi => kDebugMode && _aiFake == 'on';

class ManagerRepository extends StatelessWidget {
  final Widget child;
  final Api api;
  final NotificationService? notificationService;

  const ManagerRepository({
    super.key,
    required this.child,
    required this.api,
    this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(api),
        ),
        //specialty
        RepositoryProvider<SpecialtyRepository>(
          create: (context) => SpecialtyRepositoryImpl(api),
        ),
        //address
        RepositoryProvider<AddressRepository>(
          create: (context) =>
              AddressRepositoryImpl(api: api, apiKey: Env.googleMapsKey),
        ),
        //user status
        RepositoryProvider<UserStatusRepository>(
          create: (context) => UserStatusRepositoryImpl(api),
        ),

        //user repository
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(api: api),
        ),
        //patient repository
        RepositoryProvider<PatientRepository>(
          create: (context) => PatientRepositoryImpl(api),
        ),
        //protocol repository
        RepositoryProvider<ProtocolRepository>(
          create: (context) => ProtocolRepositoryImpl(api),
        ),
        //pathology repository
        RepositoryProvider<PathologyRepository>(
          create: (context) => PathologyRepositoryImpl(api),
        ),
        // Notification service (solo si está disponible)
        if (notificationService != null)
          RepositoryProvider<NotificationService>.value(
            value: notificationService!,
          ),
        // Notification repository
        RepositoryProvider<NotificationRepository>(
          create: (context) => NotificationRepositoryImpl(api: api),
        ),
        //order repository
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepositoryImpl(api),
        ),
        // IA (rutas /ai/app/*)
        RepositoryProvider<AiRepository>(
          create: (context) => useFakeAi
              ? FakeAiRepository()
              : AiRepositoryImpl(baseUrl: api.aiApp),
        ),
        // Reconocimiento de voz del teléfono (dictado con IA)
        RepositoryProvider<SpeechService>(
          create: (context) =>
              useFakeAi ? FakeSpeechService() : SystemSpeechService(),
        ),
        //payment movement repository
        RepositoryProvider<PaymentMovementRepository>(
          create: (context) => PaymentMovementRepositoryImpl(api: api),
        ),
      ],
      child: child,
    );
  }
}
