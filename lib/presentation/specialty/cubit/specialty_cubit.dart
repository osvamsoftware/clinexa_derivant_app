import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'specialty_state.dart';

class SpecialtyCubit extends Cubit<SpecialtyState> {
  final SpecialtyRepository _repository;

  SpecialtyCubit(this._repository) : super(const SpecialtyState());

  /// 🔹 Cargar más (paginación)
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == SpecialtyStatus.loading) return;

    final nextPage = state.page + 1;
    emit(state.copyWith(status: SpecialtyStatus.loading));

    try {
      final response = await _repository.getSpecialties(
        page: nextPage,
        limit: 20,
      );

      emit(
        state.copyWith(
          status: SpecialtyStatus.success,
          specialties: [...state.specialties, ...response.items ?? []],
          page: nextPage,
          hasMore: nextPage < (response.pages ?? 0),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SpecialtyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 🔹 Eliminar una especialidad
  Future<void> deleteSpecialty(String id) async {
    emit(state.copyWith(deleting: true));

    try {
      await _repository.deleteSpecialty(id);

      final updatedList = state.specialties
          .where((item) => item.id != id)
          .toList();

      emit(state.copyWith(deleting: false, specialties: updatedList));
    } catch (e) {
      emit(state.copyWith(deleting: false, errorMessage: e.toString()));
    }
  }

  void searchSpecialties(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(filteredSpecialties: []));
      return;
    }
    emit(state.copyWith(status: SpecialtyStatus.loading));

    try {
      final res = await _repository.getSpecialties(
        query: query,
        page: 1,
        limit: 10,
      );

      emit(
        state.copyWith(
          filteredSpecialties: res.items,
          status: SpecialtyStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          filteredSpecialties: [],
          status: SpecialtyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  //clean textfield search controller
  void clearSearch() {
    emit(SpecialtyState());
  }
}
