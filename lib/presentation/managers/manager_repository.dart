import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/services/env.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/domain/user_repository.dart';
import 'package:clinexa_derivant_app/domain/user_status_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart'; // Import
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/presentation/pathology/pathology_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerRepository extends StatelessWidget {
  final Widget child;
  final Api api;
  final NotificationService notificationService;

  const ManagerRepository({
    super.key,
    required this.child,
    required this.api,
    required this.notificationService,
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
        //notification service
        RepositoryProvider<NotificationService>.value(
          value: notificationService,
        ),
      ],
      child: child,
    );
  }
}
