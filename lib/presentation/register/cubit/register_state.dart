part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;

  // Step tracking (1 → 2 → 3)
  final int currentStep;

  final List<SpecialtyModel> specialties;
  final AddressModel? selectedAddress;
  final dynamic user;
  final String? licenseType;

  RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.currentStep = 1,
    this.specialties = const [],
    this.selectedAddress,
    this.user,
    this.licenseType,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    int? currentStep,
    List<SpecialtyModel>? specialties,
    AddressModel? selectedAddress,
    dynamic user,
    String? licenseType,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
      specialties: specialties ?? this.specialties,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      user: user ?? this.user,
      licenseType: licenseType ?? this.licenseType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    currentStep,
    specialties,
    selectedAddress,
    user,
    licenseType,
  ];
}
