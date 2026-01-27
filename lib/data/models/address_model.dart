import 'dart:convert';
import 'package:equatable/equatable.dart';

class AddressSuggestion extends Equatable {
  final String description;
  final String placeId;

  const AddressSuggestion({required this.description, required this.placeId});

  factory AddressSuggestion.fromMap(Map<String, dynamic> map) {
    return AddressSuggestion(
      description: map['description'] ?? '',
      placeId: map['place_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'description': description, 'place_id': placeId};
  }

  factory AddressSuggestion.fromJson(String source) =>
      AddressSuggestion.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  AddressSuggestion copyWith({String? description, String? placeId}) {
    return AddressSuggestion(
      description: description ?? this.description,
      placeId: placeId ?? this.placeId,
    );
  }

  @override
  List<Object> get props => [description, placeId];
}

class AddressModel extends Equatable {
  final String placeId;
  final String formattedAddress;
  final double lat;
  final double lng;
  final String? country;
  final String? city;
  final String? state;
  final String? postalCode;

  const AddressModel({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    this.country,
    this.city,
    this.state,
    this.postalCode,
    required this.placeId,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      formattedAddress: map['formatted_address'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      country: map['country'],
      city: map['city'],
      state: map['state'],
      postalCode: map['postal_code'] ?? map['zip_code'],
      placeId: map['place_id'] ?? '',
    );
  }

  factory AddressModel.fromGoogleMap(Map<String, dynamic> map) {
    final result = map['result'] ?? {};
    final location = result['geometry']?['location'] ?? {};
    final addressComponents =
        result['address_components'] as List<dynamic>? ?? [];

    String? extractComponent(String type) {
      final component = addressComponents.firstWhere(
        (c) => (c['types'] as List).contains(type),
        orElse: () => null,
      );
      return component?['long_name'];
    }

    return AddressModel(
      formattedAddress: result['formatted_address'] ?? '',
      lat: (location['lat'] ?? 0).toDouble(),
      lng: (location['lng'] ?? 0).toDouble(),
      city:
          extractComponent('locality') ??
          extractComponent('administrative_area_level_2'),
      state: extractComponent('administrative_area_level_1'),
      country: extractComponent('country'),
      postalCode: extractComponent('postal_code'),
      placeId: result['place_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "formatted_address": formattedAddress,
      "lat": lat,
      "lng": lng,
      "country": country,
      "city": city,
      "state": state,
      "postal_code": postalCode,
      "place_id": placeId,
    };
  }

  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  AddressModel copyWith({
    String? placeId,
    String? formattedAddress,
    double? lat,
    double? lng,
    String? country,
    String? city,
    String? state,
    String? postalCode,
  }) {
    return AddressModel(
      placeId: placeId ?? this.placeId,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      country: country ?? this.country,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  @override
  List<Object?> get props => [
    placeId,
    formattedAddress,
    lat,
    lng,
    country,
    city,
    state,
    postalCode,
  ];
}
