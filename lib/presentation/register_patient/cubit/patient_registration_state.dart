part of 'patient_registration_cubit.dart';

enum PatientRegistrationStatus { initial, loading, success, error }

class PatientRegistrationState extends Equatable {
  final PatientRegistrationStatus status;
  final String? errorMessage;
  final AddressModel? selectedAddress;

  const PatientRegistrationState({
    this.status = PatientRegistrationStatus.initial,
    this.errorMessage,
    this.selectedAddress,
  });

  PatientRegistrationState copyWith({
    PatientRegistrationStatus? status,
    String? errorMessage,
    AddressModel? selectedAddress,
  }) {
    return PatientRegistrationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, selectedAddress];
}
