import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:equatable/equatable.dart';

enum PatientsStatus { initial, loading, success, failure }

class PatientsState extends Equatable {
  final PatientsStatus status;
  final List<PatientModel> patients;
  final String? errorMessage;
  final bool hasReachedMax;

  // Filters
  final List<SpecialtyModel> specialties;
  final String? selectedSpecialtyId;
  final String? searchQuery;

  const PatientsState({
    this.status = PatientsStatus.initial,
    this.patients = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.specialties = const [],
    this.selectedSpecialtyId,
    this.searchQuery,
  });

  PatientsState copyWith({
    PatientsStatus? status,
    List<PatientModel>? patients,
    String? errorMessage,
    bool? hasReachedMax,
    List<SpecialtyModel>? specialties,
    String? selectedSpecialtyId,
    String? searchQuery,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      specialties: specialties ?? this.specialties,
      selectedSpecialtyId: selectedSpecialtyId ?? this.selectedSpecialtyId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    patients,
    errorMessage,
    hasReachedMax,
    specialties,
    selectedSpecialtyId,
    searchQuery,
  ];
}
