import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final NotificationService _notificationService;
  final PatientRepository _patientRepository;

  HomeCubit(this._notificationService, this._patientRepository)
    : super(const HomeState());

  Future<void> init(String userId) async {
    developer.log("🏠 [HomeCubit] init(userId: $userId) llamado");
    try {
      emit(state.copyWith(status: HomeStatus.loading));

      // Registrar dispositivo para notificaciones push
      developer.log("🏠 [HomeCubit] Ejecutando _notificationService.registerDevice()...");
      await _notificationService.registerDevice();
      developer.log("🏠 [HomeCubit] _notificationService.registerDevice() finalizado.");

      // Obtener pacientes del usuario

      // Obtener pacientes del usuario
      final patients = await _patientRepository.getAll(
        createdBy: userId,
        limit: 100, // Traemos una cantidad considerable para empezar
      );
      developer.log("🏠 [HomeCubit] Pacientes cargados: ${patients.length}");

      emit(state.copyWith(status: HomeStatus.success, patients: patients));
    } catch (e) {
      developer.log("🏠 [HomeCubit] ERROR en init: $e");
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
