import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:equatable/equatable.dart';

enum PatientInfoStatus { initial, loading, success, failure }

class PatientInfoState extends Equatable {
  final PatientInfoStatus status;
  final PatientModel? patient;
  final String? errorMessage;
  final String? successMessage;

  const PatientInfoState({
    this.status = PatientInfoStatus.initial,
    this.patient,
    this.errorMessage,
    this.successMessage,
  });

  PatientInfoState copyWith({
    PatientInfoStatus? status,
    PatientModel? patient,
    String? errorMessage,
    String? successMessage,
  }) {
    return PatientInfoState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, patient, errorMessage, successMessage];
}
