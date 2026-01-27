import 'package:clinexa_derivant_app/data/models/address_model.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit(this.repository) : super(AddressState());

  void search(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(suggestions: [], status: Status.initial));
      return;
    }

    emit(state.copyWith(status: Status.loading));

    try {
      final results = await repository.searchAddress(query);

      emit(state.copyWith(suggestions: results, status: Status.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.error,
          errorMessage: "Error al buscar direcciones",
        ),
      );
    }
  }

  Future<void> selectPlace(String placeId) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final detail = await repository.getAddressDetail(placeId);

      if (detail != null) {
        emit(
          state.copyWith(
            selectedAddress: detail,
            status: Status.success,
            suggestions: [], // limpiamos sugerencias
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: Status.error,
            errorMessage: "No se encontraron detalles de la dirección",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.error,
          errorMessage: "Error al obtener detalles",
        ),
      );
    }
  }
}
