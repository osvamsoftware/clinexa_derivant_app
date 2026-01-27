import 'dart:async'; // Add async for debounce if needed, though simple query is fine for now
import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/presentation/patients/cubit/patients_state.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final PatientRepository _patientRepository;
  final SpecialtyRepository _specialtyRepository;
  final String userId;
  Timer? _debounce;

  PatientsCubit({
    required PatientRepository patientRepository,
    required SpecialtyRepository specialtyRepository,
    required this.userId,
  }) : _patientRepository = patientRepository,
       _specialtyRepository = specialtyRepository,
       super(const PatientsState());

  Future<void> loadPatients() async {
    emit(state.copyWith(status: PatientsStatus.loading));

    try {
      final List<PatientModel> patients;

      if (state.selectedSpecialtyId != null &&
          state.selectedSpecialtyId!.isNotEmpty) {
        patients = await _patientRepository.searchByCreatorSpecialty(
          createdBy: userId,
          specialtyId: state.selectedSpecialtyId!,
          search: state.searchQuery,
          limit: 100,
        );
      } else {
        patients = await _patientRepository.getAll(
          createdBy: userId,
          limit: 100,
          search: state.searchQuery,
          // When no specialty is selected, we don't pass specialtyId to getAll
          // assuming getAll handles basic filtering.
        );
      }

      emit(state.copyWith(status: PatientsStatus.success, patients: patients));
    } catch (e) {
      emit(
        state.copyWith(
          status: PatientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadSpecialties() async {
    try {
      final response = await _specialtyRepository.getSpecialties(limit: 100);
      emit(state.copyWith(specialties: response.items ?? []));
    } catch (e) {
      // Log error but don't fail the whole screen if specialties fail
      print("Error loading specialties: $e");
    }
  }

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      emit(state.copyWith(searchQuery: query));
      loadPatients();
    });
  }

  void setSpecialtyId(String? id) {
    emit(state.copyWith(selectedSpecialtyId: id)); // Use null to clear
    loadPatients();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
