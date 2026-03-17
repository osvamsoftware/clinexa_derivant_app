import 'package:clinexa_derivant_app/data/models/address_model.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/domain/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository userRepository;
  final SpecialtyRepository specialtyRepository;
  final UserModel currentUser;

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final specialtyController = TextEditingController();

  EditProfileCubit({
    required this.userRepository,
    required this.specialtyRepository,
    required this.currentUser,
  }) : super(const EditProfileState()) {
    _init();
  }

  void _init() {
    firstNameController.text = currentUser.firstName ?? '';
    lastNameController.text = currentUser.lastName ?? '';

    // Address
    if (currentUser.addressModel != null) {
      emit(state.copyWith(selectedAddress: currentUser.addressModel));
      addressController.text = currentUser.addressModel!.formattedAddress;
    }

    // Load specialties
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    if (currentUser.specialties.isEmpty) return;

    try {
      final List<SpecialtyModel> loaded = [];
      for (final id in currentUser.specialties) {
        final s = await specialtyRepository.getSpecialtyById(id);
        loaded.add(s);
      }
      emit(state.copyWith(specialties: loaded));
    } catch (e) {
      // Error al cargar especialidades, se continúa sin ellas
    }
  }

  // Address
  void setAddress(AddressModel address) {
    emit(state.copyWith(selectedAddress: address));
    addressController.text = address.formattedAddress;
  }

  void clearAddress() {
    emit(state.copyWith(clearSelectedAddress: true));
    addressController.clear();
  }

  // Specialties
  void addSpecialty(SpecialtyModel specialty) {
    final list = List<SpecialtyModel>.from(state.specialties);
    if (!list.any((e) => e.id == specialty.id)) {
      list.add(specialty);
      emit(state.copyWith(specialties: list));
    }
    specialtyController.clear();
  }

  void removeSpecialty(SpecialtyModel specialty) {
    final list = List<SpecialtyModel>.from(state.specialties);
    list.removeWhere((e) => e.id == specialty.id);
    emit(state.copyWith(specialties: list));
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    // Validation for Address
    if (state.selectedAddress == null) {
      emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: "Debes seleccionar una dirección válida",
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.loading));

    try {
      final updatedUser = currentUser.copyWith(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        addressModel: state.selectedAddress,
        specialties: state.specialties.map((e) => e.id).toList(),
      );

      await userRepository.updateUser(updatedUser);

      emit(state.copyWith(status: EditProfileStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
