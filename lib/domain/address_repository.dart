import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressSuggestion>> searchAddress(String query);
  Future<AddressModel?> getAddressDetail(String placeId);
}

class AddressRepositoryImpl implements AddressRepository {
  final ApiService _api = ApiService(); // estándar Clinexa
  final Api api;
  final String apiKey;

  AddressRepositoryImpl({required this.api, required this.apiKey});

  // =============================================================
  // 🔹 SEARCH ADDRESS (GOOGLE AUTOCOMPLETE)
  // =============================================================
  @override
  Future<List<AddressSuggestion>> searchAddress(String query) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.googleAutocomplete,
        method: HttpMethod.get,
        withAuth: false,
        query: {
          "input": query,
          "key": apiKey,
          "language": "es",
          "components": "country:ar",
        },
        fromJson: (json) => json,
      );

      final predictions = res.data?["predictions"] ?? [];

      return predictions
          .map<AddressSuggestion>((e) => AddressSuggestion.fromMap(e))
          .toList();
    } catch (e) {
      print("❌ [AddressRepository.searchAddress] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET ADDRESS DETAIL (GOOGLE PLACE DETAILS)
  // =============================================================
  @override
  Future<AddressModel?> getAddressDetail(String placeId) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.googlePlaceDetails,
        method: HttpMethod.get,
        withAuth: false,
        query: {"place_id": placeId, "key": apiKey, "language": "es"},
        fromJson: (json) => json,
      );

      return AddressModel.fromGoogleMap(res.data ?? {});
    } catch (e) {
      print("❌ [AddressRepository.getAddressDetail] $e");
      rethrow;
    }
  }
}
