import 'package:clinexa_derivant_app/data/models/address_model.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository authRepository;

  // 📌 Form keys (uno por pantalla)
  final formStep1Key = GlobalKey<FormState>();
  final formStep2Key = GlobalKey<FormState>();
  final formStep3Key = GlobalKey<FormState>();

  // 📌 Controllers — Step 1
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // 📌 Controllers — Step 2
  final licenseController = TextEditingController();
  final specialtyController = TextEditingController();

  // 📌 Controllers — Step 3
  final biographyController = TextEditingController();
  final addressController = TextEditingController();

  RegisterCubit(this.authRepository) : super(RegisterState());

  // =============================================================
  // 🔹 STEP NAVIGATION
  // =============================================================
  void goToStep(int step) => emit(state.copyWith(currentStep: step));

  // =============================================================
  // 🔹 SPECIALTIES MANAGEMENT
  // =============================================================
  void addSpecialty(SpecialtyModel specialty) {
    final list = List<SpecialtyModel>.from(state.specialties);
    if (!list.contains(specialty)) {
      list.add(specialty);
      emit(state.copyWith(specialties: list));
    }
    specialtyController.clear();
  }

  void removeSpecialty(String s) {
    final list = List<SpecialtyModel>.from(state.specialties);
    list.removeWhere((element) => element.id == s);
    emit(state.copyWith(specialties: list));
  }

  // =============================================================
  // 🔹 SET ADDRESS (Google Places)
  // =============================================================
  void setAddressDetail({AddressModel? detail}) {
    emit(state.copyWith(selectedAddress: detail));
  }

  // =============================================================
  // 🔹 SET LICENSE TYPE
  // =============================================================
  void setLicenseType(String? type) {
    emit(state.copyWith(licenseType: type));
  }

  // =============================================================
  // 🔹 SUBMIT — FINAL STEP
  // =============================================================
  Future<void> submit() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (state.selectedAddress == null) {
      emit(
        state.copyWith(
          status: RegisterStatus.error,
          errorMessage: "Selecciona una dirección válida.",
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      final detail = state.selectedAddress!;

      // =============================================================
      // 🔥 Crear el modelo de usuario completo
      // =============================================================
      final user = UserModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        role: "derivant",
        medicalLicense: licenseController.text.trim(),
        licenceType: state.licenseType,
        specialties: List.from(state.specialties.map((e) => e.id)),
        biography: biographyController.text.trim(),
        addressModel: detail,
      );

      // =============================================================
      // 🔥 Enviar registro al backend
      // =============================================================
      final newUser = await authRepository.register(
        user: user,
        password: passController.text.trim(),
      );

      emit(state.copyWith(status: RegisterStatus.success, user: newUser));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
