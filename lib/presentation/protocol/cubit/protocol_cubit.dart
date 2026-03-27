import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_state.dart';

class ProtocolCubit extends Cubit<ProtocolState> {
  final ProtocolRepository _repository;
  static const int _limit = 10;

  ProtocolCubit(this._repository) : super(const ProtocolState());

  Future<void> loadProtocols({bool refresh = false}) async {
    if (state.status == ProtocolStatus.loading) return;
    if (state.hasReachedMax && !refresh) return;

    final page = refresh ? 1 : state.page;
    if (refresh) {
      emit(
        state.copyWith(
          status: ProtocolStatus.loading,
          page: 1,
          protocols: [],
          hasReachedMax: false,
        ),
      );
    } else {
      // Don't emit loading on pagination to avoid full screen loader,
      // but UI can show bottom loader based on scroll
    }

    try {
      final response = await _repository.getProtocolsByCategories(
        specialties: state.selectedUseIds.isNotEmpty
            ? state.selectedUseIds
            : null,
        pathologies: state.selectedPathologyIds.isNotEmpty
            ? state.selectedPathologyIds
            : null,
        query: state.query,
        page: page,
        limit: _limit,
      );

      final newProtocols = response.items ?? [];
      final hasReachedMax = newProtocols.length < _limit;

      emit(
        state.copyWith(
          status: ProtocolStatus.success,
          protocols: refresh
              ? newProtocols
              : [...state.protocols, ...newProtocols],
          hasReachedMax: hasReachedMax,
          page: page + 1,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProtocolStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void updateFilters({
    List<String>? useIds,
    List<String>? pathologyIds,
    String? query,
    bool clearQuery = false,
  }) {
    emit(
      state.copyWith(
        selectedUseIds: useIds,
        selectedPathologyIds: pathologyIds,
        query: query,
        clearQuery: clearQuery,
      ),
    );
    loadProtocols(refresh: true);
  }

  void applySpecialty(String specialtyId) {
    updateFilters(
      useIds: [specialtyId],
      pathologyIds: [], // Reset pathologies when specialty changes
      clearQuery: true,
    );
  }

  void applyPathology(String pathologyId) {
    updateFilters(
      useIds: state.selectedUseIds,
      pathologyIds: [pathologyId],
      clearQuery: true,
    );
  }

  void applyQuery(String query) {
    updateFilters(
      useIds: state.selectedUseIds,
      pathologyIds: [],
      query: query,
    );
  }
}
