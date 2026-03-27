import 'dart:developer';
 import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientInfoCubit extends Cubit<PatientInfoState> {
  final PatientRepository patientRepository;
  final OrderRepository orderRepository;

  PatientInfoCubit({
    required this.patientRepository,
    required this.orderRepository,
    required PatientModel initialPatient,
  }) : super(PatientInfoState(patient: initialPatient)) {
    // Si el paciente tiene una orden pero no los detalles, cargarla
    if (initialPatient.currentOrderId != null && initialPatient.order == null) {
      loadOrder(initialPatient.id!);
    }
  }

  Future<void> loadOrder(String patientId) async {
    try {
      final order = await orderRepository.getOrderByPatientId(patientId);
      if (order != null && state.patient != null) {
        emit(
          state.copyWith(
            patient: state.patient!.copyWith(order: order),
          ),
        );
      }
    } catch (e) {
      log('Error al cargar orden del paciente', error: e);
    }
  }

  Future<void> loadPatient(String patientId) async {
    try {
      emit(state.copyWith(status: PatientInfoStatus.loading));

      final patient = await patientRepository.getById(patientId);

      emit(state.copyWith(status: PatientInfoStatus.success, patient: patient));
    } catch (e, stack) {
      log('Error al cargar paciente', error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: PatientInfoStatus.failure,
          errorMessage: 'Error al cargar los datos del paciente',
        ),
      );
    }
  }

  Future<void> updatePatientStatus(String newStatus) async {
    if (state.patient == null) return;

    try {
      emit(state.copyWith(status: PatientInfoStatus.loading));

      final updatedPatient = state.patient!.copyWith(status: newStatus);

      final result = await patientRepository.update(
        state.patient!.id!,
        updatedPatient,
      );

      emit(
        state.copyWith(
          status: PatientInfoStatus.success,
          patient: result,
          successMessage: 'Estado del paciente actualizado correctamente',
        ),
      );
    } catch (e, stack) {
      log(
        'Error al actualizar estado del paciente',
        error: e,
        stackTrace: stack,
      );
      emit(
        state.copyWith(
          status: PatientInfoStatus.failure,
          errorMessage: 'Error al actualizar el estado del paciente',
        ),
      );
    }
  }
}
