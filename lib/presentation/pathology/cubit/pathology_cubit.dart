import 'package:clinexa_derivant_app/data/models/pathology_model.dart';
import 'package:clinexa_derivant_app/presentation/pathology/pathology_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pathology_state.dart';

class PathologyCubit extends Cubit<PathologyState> {
  final PathologyRepository _repository;

  PathologyCubit(this._repository) : super(const PathologyState());

  /// 🔹 Cargar más (paginación)
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == PathologyStatus.loading) return;

    final nextPage = state.page + 1;
    emit(state.copyWith(status: PathologyStatus.loading));

    try {
      final response = await _repository.getPathologies(
        page: nextPage,
        limit: 20,
      );

      emit(
        state.copyWith(
          status: PathologyStatus.success,
          pathologies: [...state.pathologies, ...response.items ?? []],
          page: nextPage,
          hasMore: nextPage < (response.pages ?? 0),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PathologyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 🔹 Eliminar una patologia
  Future<void> deletePathology(String id) async {
    emit(state.copyWith(deleting: true));

    try {
      await _repository.deletePathology(id);

      final updatedList = state.pathologies
          .where((item) => item.id != id)
          .toList();

      emit(state.copyWith(deleting: false, pathologies: updatedList));
    } catch (e) {
      emit(state.copyWith(deleting: false, errorMessage: e.toString()));
    }
  }

  void searchPathologies(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(filteredPathologies: []));
      return;
    }
    emit(state.copyWith(status: PathologyStatus.loading));

    try {
      final res = await _repository.getPathologies(
        query: query,
        page: 1,
        limit: 10,
      );

      emit(
        state.copyWith(
          filteredPathologies: res.items,
          status: PathologyStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          filteredPathologies: [],
          status: PathologyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  //clean textfield search controller
  void clearSearch() {
    emit(const PathologyState());
  }
}
