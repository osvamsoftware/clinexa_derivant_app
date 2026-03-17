import 'package:clinexa_derivant_app/data/models/address_model.dart';

class UserModel {
  final String? id;

  // Basic info
  final String email;
  final String role;
  final String? firebaseId;

  final String? firstName;
  final String? lastName;
  final String? password;

  // Medical info
  final String? medicalLicense;
  final String? licenseType; // Fixed spelling
  final List<String> specialties;
  final String? clinicId;
  final String? biography;
  final List<String>? protocols;

  // Profile
  final String? profileImage;
  final AddressModel? addressModel;

  // Devices
  final List<Map<String, dynamic>> devices;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? provincialLicenseName;

  UserModel({
    this.id,
    required this.email,
    required this.role,
    this.firebaseId,
    this.firstName,
    this.lastName,
    this.password,
    this.medicalLicense,
    this.specialties = const [],
    this.clinicId,
    this.biography,
    this.profileImage,
    this.addressModel,
    this.devices = const [],
    this.createdAt,
    this.updatedAt,
    this.protocols = const [],
    this.licenseType, // Fixed spelling
    this.provincialLicenseName,
  });

  // ------------------------------------------------------------
  // FROM MAP
  // ------------------------------------------------------------
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',

      firebaseId: json['firebase_id'],

      firstName: json['first_name'],
      lastName: json['last_name'],
      password: json['password'], // normalmente backend NO lo devuelve

      medicalLicense: json['medical_license'],
      specialties: List<String>.from(json['specialties'] ?? []),
      clinicId: json['clinic_id'],
      biography: json['biography'],

      profileImage: json['profile_image'],

      addressModel: json['address_model'] != null
          ? AddressModel.fromMap(json['address_model'])
          : null,

      devices: List<Map<String, dynamic>>.from(json['devices'] ?? []),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      protocols: List<String>.from(json['protocols'] ?? []),
      licenseType: json['license_type'], // Fixed key
      provincialLicenseName: json['provincial_license_name'],
    );
  }

  // ------------------------------------------------------------
  // TO MAP
  // (para crear o actualizar usuario)
  // ------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      if (id != null) "_id": id,
      "email": email,
      "role": role,

      if (firebaseId != null) "firebase_id": firebaseId,

      if (firstName != null) "first_name": firstName,
      if (lastName != null) "last_name": lastName,
      if (password != null) "password": password,

      "medical_license": medicalLicense,
      "specialties": specialties,
      "clinic_id": clinicId,
      "biography": biography,
      "profile_image": profileImage,

      "address_model": addressModel?.toMap(),

      "devices": devices,

      if (createdAt != null) "created_at": createdAt!.toIso8601String(),
      if (updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
      "protocols": protocols,
      "license_type": licenseType, // Fixed key
      "provincial_license_name": provincialLicenseName,
    };
  }

  //copywith
  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? firebaseId,
    String? firstName,
    String? lastName,
    String? password,
    String? medicalLicense,
    List<String>? specialties,
    String? clinicId,
    String? biography,
    List<String>? protocols,
    String? profileImage,
    AddressModel? addressModel,
    List<Map<String, dynamic>>? devices,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? licenseType, // Fixed spelling
    String? provincialLicenseName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      firebaseId: firebaseId ?? this.firebaseId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      medicalLicense: medicalLicense ?? this.medicalLicense,
      specialties: specialties ?? this.specialties,
      clinicId: clinicId ?? this.clinicId,
      biography: biography ?? this.biography,
      protocols: protocols ?? this.protocols,
      profileImage: profileImage ?? this.profileImage,
      addressModel: addressModel ?? this.addressModel,
      devices: devices ?? this.devices,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      licenseType: licenseType ?? this.licenseType,
      provincialLicenseName:
          provincialLicenseName ?? this.provincialLicenseName,
    );
  }
}
