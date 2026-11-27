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

  /// Sube cuando cambian la fecha de nacimiento, el sexo o las notas desde
  /// fuera del teclado (dictado o IA), para redibujar esos campos.
  final int formRevision;

  const PatientRegistrationState({
    this.formRevision = 0,
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
    int? formRevision,
  }) {
    return PatientRegistrationState(
      formRevision: formRevision ?? this.formRevision,
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
    formRevision,
  ];
}
