part of 'edit_profile_cubit.dart';

enum EditProfileStatus { initial, loading, success, error }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final String? errorMessage;
  final List<SpecialtyModel> specialties;
  final AddressModel? selectedAddress;

  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.errorMessage,
    this.specialties = const [],
    this.selectedAddress,
  });

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? errorMessage,
    List<SpecialtyModel>? specialties,
    AddressModel? selectedAddress,
    bool clearSelectedAddress = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      specialties: specialties ?? this.specialties,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    specialties,
    selectedAddress,
  ];
}
