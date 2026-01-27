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

  PatientRegistrationCubit(this._repository, {this.protocolId})
    : super(const PatientRegistrationState());

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

  // State values (Non-text fields)
  DateTime? birthDate;
  String? gender;

  // TODO: Add Lists for specialties/pathologies if UI supports it

  void setBirthDate(DateTime date) {
    birthDate = date;
    birthDateController.text = "${date.year}-${date.month}-${date.day}";
  }

  void setGender(String? value) {
    gender = value;
  }

  // Method to set address from Google Maps selection
  void setAddress(AddressModel addressModel) {
    emit(state.copyWith(selectedAddress: addressModel));

    addressController.text = addressModel.formattedAddress;
    cityController.text = addressModel.city ?? '';
    stateController.text = addressModel.state ?? '';
    countryController.text = addressModel.country ?? '';
    postalCodeController.text = addressModel.postalCode ?? '';
  }

  Future<void> register({String? createdBy}) async {
    if (!formKey.currentState!.validate()) return;

    // Logic to handle address selection
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

    emit(
      state.copyWith(
        status: PatientRegistrationStatus.loading,
        selectedAddress: state.selectedAddress, // Preserve address
      ),
    );

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
        specialties: [], // Todo implement UI for this
        pathologies: [], // Todo implement UI for this
        protocolId: protocolId,
        createdBy: createdBy,
      );

      await _repository.create(patient);

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
