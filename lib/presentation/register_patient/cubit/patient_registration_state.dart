part of 'patient_registration_cubit.dart';

enum PatientRegistrationStatus {
  initial,
  loading,
  formCompleted,
  signatureCompleted,
  success,
  error,
}

class PatientRegistrationState extends Equatable {
  final PatientRegistrationStatus status;
  final String? errorMessage;
  final AddressModel? selectedAddress;

  // Firma
  final Uint8List? signatureBytes;
  final String? signatureUrl;

  const PatientRegistrationState({
    this.status = PatientRegistrationStatus.initial,
    this.errorMessage,
    this.selectedAddress,
    this.signatureBytes,
    this.signatureUrl,
  });

  PatientRegistrationState copyWith({
    PatientRegistrationStatus? status,
    String? errorMessage,
    AddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    Uint8List? signatureBytes,
    String? signatureUrl,
  }) {
    return PatientRegistrationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      signatureBytes: signatureBytes ?? this.signatureBytes,
      signatureUrl: signatureUrl ?? this.signatureUrl,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    selectedAddress,
    signatureBytes,
    signatureUrl,
  ];
}
