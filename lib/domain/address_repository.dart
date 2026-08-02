import 'dart:developer' as developer;
import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressSuggestion>> searchAddress(String query);
  Future<AddressModel?> getAddressDetail(String placeId);
}

/// Error del servicio de direcciones de Google.
///
/// Google responde **HTTP 200 incluso cuando rechaza la petición**: el motivo
/// real viaja en el campo `status` del cuerpo. Sin mirarlo, un rechazo se
/// confunde con "no hay resultados" y el usuario ve un desplegable vacío sin
/// ninguna explicación.
class AddressServiceException implements Exception {
  final String status;
  final String? googleMessage;

  AddressServiceException(this.status, [this.googleMessage]);

  /// Mensaje para el usuario, según lo que haya fallado de verdad.
  String get userMessage {
    if (status == 'MISSING_API_KEY') {
      return 'La app se compiló sin la clave de Google Maps. '
          'Arráncala con: flutter run --dart-define-from-file=.env';
    }

    switch (status) {
      case 'REQUEST_DENIED':
        return 'El servicio de direcciones no está disponible. '
            'Puedes escribir la dirección manualmente.';
      case 'OVER_QUERY_LIMIT':
        return 'Se alcanzó el límite de búsquedas. Inténtalo en unos minutos '
            'o escribe la dirección manualmente.';
      case 'INVALID_REQUEST':
        return 'La búsqueda no es válida. Prueba con más caracteres.';
      default:
        return 'No se pudieron buscar direcciones. '
            'Puedes escribirla manualmente.';
    }
  }

  @override
  String toString() =>
      'AddressServiceException($status)'
      '${googleMessage != null ? ": $googleMessage" : ""}';
}

/// Estados de la API de Google que no son un fallo.
const _okStatuses = {'OK', 'ZERO_RESULTS'};

class AddressRepositoryImpl implements AddressRepository {
  final ApiService _api = ApiService(); // estándar Clinexa
  final Api api;
  final String apiKey;

  AddressRepositoryImpl({required this.api, required this.apiKey});

  // =============================================================
  // 🔹 SEARCH ADDRESS (GOOGLE AUTOCOMPLETE)
  // =============================================================
  /// Sin clave no tiene sentido llamar: Google responde "You must use an API
  /// key...", un mensaje que no dice lo que realmente pasa —que el build no
  /// recibió la configuración—.
  void _requireApiKey() {
    if (apiKey.isEmpty) {
      developer.log(
        'GOOGLE_MAPS_API_KEY vacía: la app se compiló sin --dart-define-from-file',
      );
      throw AddressServiceException('MISSING_API_KEY');
    }
  }

  @override
  Future<List<AddressSuggestion>> searchAddress(String query) async {
    _requireApiKey();
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

      // Google devuelve 200 aunque rechace la petición: el motivo está en
      // `status`. Sin comprobarlo, un rechazo parecía "sin resultados".
      final status = res.data?["status"] as String? ?? 'UNKNOWN_ERROR';
      if (!_okStatuses.contains(status)) {
        final message = res.data?["error_message"] as String?;
        developer.log('Places autocomplete rechazado: $status');
        throw AddressServiceException(status, message);
      }

      final predictions = res.data?["predictions"] ?? [];

      return predictions
          .map<AddressSuggestion>((e) => AddressSuggestion.fromMap(e))
          .toList();
    } on AddressServiceException {
      rethrow;
    } catch (e) {
      developer.log("❌ [AddressRepository.searchAddress] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET ADDRESS DETAIL (GOOGLE PLACE DETAILS)
  // =============================================================
  @override
  Future<AddressModel?> getAddressDetail(String placeId) async {
    _requireApiKey();
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.googlePlaceDetails,
        method: HttpMethod.get,
        withAuth: false,
        query: {"place_id": placeId, "key": apiKey, "language": "es"},
        fromJson: (json) => json,
      );

      final status = res.data?["status"] as String? ?? 'UNKNOWN_ERROR';
      if (!_okStatuses.contains(status)) {
        final message = res.data?["error_message"] as String?;
        developer.log('Place details rechazado: $status');
        throw AddressServiceException(status, message);
      }

      return AddressModel.fromGoogleMap(res.data ?? {});
    } catch (e) {
      developer.log("❌ [AddressRepository.getAddressDetail] $e");
      rethrow;
    }
  }
}
