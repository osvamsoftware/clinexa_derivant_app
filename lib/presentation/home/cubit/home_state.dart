import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final String? errorMessage;
  final List<PatientModel> patients;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.patients = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    List<PatientModel>? patients,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, patients];
}
