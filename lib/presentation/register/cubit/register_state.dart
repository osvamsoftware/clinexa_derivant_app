part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;

  final List<SpecialtyModel> specialties;
  final AddressModel? selectedAddress;
  final dynamic user;
  final String? licenseType;
  final String? provincialLicenseName;
  final bool termsAccepted;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.specialties = const [],
    this.selectedAddress,
    this.user,
    this.licenseType,
    this.provincialLicenseName,
    this.termsAccepted = false,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    List<SpecialtyModel>? specialties,
    AddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    dynamic user,
    String? licenseType,
    String? provincialLicenseName,
    bool? termsAccepted,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      specialties: specialties ?? this.specialties,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      user: user ?? this.user,
      licenseType: licenseType ?? this.licenseType,
      provincialLicenseName:
          provincialLicenseName ?? this.provincialLicenseName,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    specialties,
    selectedAddress,
    user,
    licenseType,
    provincialLicenseName,
    termsAccepted,
  ];
}
