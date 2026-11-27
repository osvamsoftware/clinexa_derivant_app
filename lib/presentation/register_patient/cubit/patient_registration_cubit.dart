import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/address_model.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'patient_registration_state.dart';

class PatientRegistrationCubit extends Cubit<PatientRegistrationState> {
  final PatientRepository _repository;
  final String? protocolId;

  PatientRegistrationCubit(
    this._repository, {
    this.protocolId,
    this.onPatientCreated,
  }) : super(const PatientRegistrationState());

  /// Se llama con el id del paciente recién creado (por ejemplo, para
  /// vincularle la pre-evaluación de la IA). Sus errores no afectan el
  /// registro.
  final Future<void> Function(String patientId)? onPatientCreated;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // State values
  DateTime? birthDate;
  String? gender;

  void setBirthDate(DateTime date) {
    birthDate = date;
    birthDateController.text = "${date.year}-${date.month}-${date.day}";
    _touch();
  }

  void setGender(String? value) {
    gender = value;
    _touch();
  }

  /// Avisa que cambiaron campos que no viven en el estado (fecha, sexo).
  void _touch() => emit(state.copyWith(formRevision: state.formRevision + 1));

  /// Agrega un bloque al final de las notas clínicas (dictado o lectura de
  /// estudios con IA), separado por una línea en blanco.
  void appendNotes(String text) {
    final block = text.trim();
    if (block.isEmpty) return;
    final current = notesController.text.trimRight();
    notesController.text = current.isEmpty ? block : '$current\n\n$block';
    _touch();
  }

  void setAddress(AddressModel addressModel) {
    emit(state.copyWith(selectedAddress: addressModel));

    addressController.text = addressModel.formattedAddress;
    cityController.text = addressModel.city ?? '';
    stateController.text = addressModel.state ?? '';
    countryController.text = addressModel.country ?? '';
    postalCodeController.text = addressModel.postalCode ?? '';
  }

  void clearAddress() {
    emit(state.copyWith(clearSelectedAddress: true));
    addressController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();
  }

  bool validatePersonalData() {
    return formKey.currentState?.validate() ?? false;
  }

  // Método para completar el formulario y navegar a firma
  void completeForm() {
    if (!validatePersonalData()) {
      return;
    }
    emit(state.copyWith(status: PatientRegistrationStatus.formCompleted));
  }

  // Métodos de firma
  // Métodos de firma
  void setSignatureUrl(String url, Uint8List signatureBytes) {
    emit(
      state.copyWith(
        signatureBytes: signatureBytes,
        signatureUrl: url,
        status: PatientRegistrationStatus.signatureCompleted,
      ),
    );
  }

  void clearSignature() {
    emit(state.copyWith(signatureBytes: Uint8List(0), signatureUrl: ''));
  }

  // Método público para guardar el paciente (llamado desde PatientVerificationScreen)
  Future<void> savePatient({String? createdBy}) async {
    emit(state.copyWith(status: PatientRegistrationStatus.loading));

    final selectedAddress = state.selectedAddress;

    final addressToSend =
        selectedAddress ??
        (addressController.text.isNotEmpty
            ? AddressModel(
                formattedAddress: addressController.text,
                lat: 0,
                lng: 0,
                city: cityController.text,
                state: stateController.text,
                country: countryController.text,
                postalCode: postalCodeController.text,
                placeId: '',
              )
            : null);

    try {
      final patient = PatientModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dni: dniController.text.trim(),
        birthDate: birthDate,
        gender: gender,
        phone: phoneController.text.trim(),
        phone2: phone2Controller.text.trim(),
        email: emailController.text.trim(),
        address: addressToSend,
        notes: notesController.text.trim(),
        specialties: [],
        pathologies: [],
        protocolId: protocolId,
        signatureUrl: state.signatureUrl,
        createdBy: createdBy,
      );

      final created = await _repository.create(patient);
      final id = created.id;
      if (id != null && id.isNotEmpty && onPatientCreated != null) {
        unawaited(onPatientCreated!(id).catchError((Object _) {}));
      }

      emit(state.copyWith(status: PatientRegistrationStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: PatientRegistrationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    dniController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    notesController.dispose();
    birthDateController.dispose();
    return super.close();
  }
}
