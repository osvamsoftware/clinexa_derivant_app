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
    print("🏠 [HomeCubit] init(userId: $userId) llamado");
    try {
      emit(state.copyWith(status: HomeStatus.loading));

      // Registrar dispositivo para notificaciones push
      print("🏠 [HomeCubit] Ejecutando _notificationService.registerDevice()...");
      await _notificationService.registerDevice();
      print("🏠 [HomeCubit] _notificationService.registerDevice() finalizado.");

      // Obtener pacientes del usuario

      // Obtener pacientes del usuario
      final patients = await _patientRepository.getAll(
        createdBy: userId,
        limit: 100, // Traemos una cantidad considerable para empezar
      );
      print("🏠 [HomeCubit] Pacientes cargados: ${patients.length}");

      emit(state.copyWith(status: HomeStatus.success, patients: patients));
    } catch (e) {
      print("🏠 [HomeCubit] ERROR en init: $e");
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
