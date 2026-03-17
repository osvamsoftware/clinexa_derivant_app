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
  final addressController = TextEditingController();

  RegisterCubit(this.authRepository) : super(RegisterState());

  // =============================================================
  // 🔹 STEP 1 VALIDATION (Email Check)
  // =============================================================
  Future<bool> validateStep1() async {
    // 1. Validar formato (aunque el form ya lo hace, doble check)
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      emit(
        state.copyWith(
          status: RegisterStatus.error,
          errorMessage: "Ingrese un correo válido",
        ),
      );
      return false;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      final exists = await authRepository.checkEmailExists(
        emailController.text.trim(),
      );
      if (exists) {
        emit(
          state.copyWith(
            status: RegisterStatus.error,
            errorMessage: "El correo electrónico ya está registrado.",
          ),
        );
        return false;
      }
      // Si no existe, reseteamos status y retornamos true para que la UI navegue
      emit(state.copyWith(status: RegisterStatus.initial));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.error,
          errorMessage: "Error al verificar el correo: $e",
        ),
      );
      return false;
    }
  }

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

  void clearAddress() {
    emit(state.copyWith(clearSelectedAddress: true));
    addressController.clear();
  }

  // =============================================================
  // 🔹 SET LICENSE TYPE
  // =============================================================
  void setLicenseType(String? type) {
    emit(state.copyWith(licenseType: type));
  }

  // =============================================================
  // 🔹 SET PROVINCIAL LICENSE
  // =============================================================
  void setProvincialLicenseName(String? name) {
    emit(state.copyWith(provincialLicenseName: name));
  }

  // =============================================================
  // 🔹 TOGGLE TERMS
  // =============================================================
  void toggleTerms(bool? value) {
    emit(state.copyWith(termsAccepted: value ?? false));
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

      // Determinar si enviamos la provincia o null
      final provincialLicense = (state.licenseType == 'provincial')
          ? state.provincialLicenseName
          : null;

      // =============================================================
      // 🔥 Crear el modelo de usuario completo
      // =============================================================
      final user = UserModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        role: "derivant",
        medicalLicense: licenseController.text.trim(),
        licenseType: state.licenseType,
        provincialLicenseName: provincialLicense,
        specialties: List.from(state.specialties.map((e) => e.id)),
        biography: "",
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
