import 'package:clinexa_derivant_app/data/models/order_model.dart';
import 'package:equatable/equatable.dart';

import 'package:clinexa_derivant_app/data/models/address_model.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';

class PatientModel extends Equatable {
  final String? id;

  // Identidad básica
  final String firstName;
  final String lastName;
  final String? dni;
  final DateTime? birthDate;
  final String? gender;

  // Contacto (Refactored to match cleanup rules)
  final String? phone;
  final String? phone2;
  final String? email;
  final AddressModel? address;

  // Información médica
  final List<String> specialties; // IDs
  final List<String> pathologies; // IDs
  final String? protocolId; // New field
  final ProtocolModel? protocol; // Protocolo completo
  final String? notes;

  // Relación con médicos
  final String? createdBy; // ID
  final String? assignedTo; // ID

  // Estado
  final String status;

  // Auditoría
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? currentOrderId;
  final OrderModel? order;

  const PatientModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.dni,
    this.birthDate,
    this.gender,
    this.phone,
    this.phone2,
    this.email,
    this.address,
    this.specialties = const [],
    this.pathologies = const [],
    this.protocolId,
    this.protocol,
    this.notes,
    this.createdBy,
    this.assignedTo,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.currentOrderId,
    this.order,
  });

  // Helpers
  String get fullName => "$firstName $lastName";

  factory PatientModel.fromMap(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'] ?? json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dni: json['dni'],
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      gender: json['gender'],
      phone: json['phone'],
      phone2: json['phone2'],
      email: json['email'],
      address: json['address'] != null
          ? AddressModel.fromMap(json['address'])
          : null,
      specialties: List<String>.from(json['specialties'] ?? []),
      pathologies: List<String>.from(json['pathologies'] ?? []),
      protocolId: json['protocol_id'],
      protocol: json['protocol'] != null
          ? ProtocolModel.fromMap(json['protocol'])
          : null,
      notes: json['notes'],
      createdBy: json['created_by'],
      assignedTo: json['assigned_to'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      currentOrderId: json['current_order_id'],
      order: json['order'] != null ? OrderModel.fromMap(json['order']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "_id": id,
      "first_name": firstName,
      "last_name": lastName,
      if (dni != null) "dni": dni,
      if (birthDate != null) "birth_date": birthDate!.toIso8601String(),
      if (gender != null) "gender": gender,
      if (phone != null) "phone": phone,
      if (phone2 != null) "phone2": phone2,
      if (email != null) "email": email,
      if (address != null) "address": address!.toMap(),
      "specialties": specialties,
      "pathologies": pathologies,
      if (protocolId != null) "protocol_id": protocolId,
      if (protocol != null) "protocol": protocol!.toMap(),
      if (notes != null) "notes": notes,
      if (createdBy != null) "created_by": createdBy,
      if (assignedTo != null) "assigned_to": assignedTo,
      "status": status,
      if (createdAt != null) "created_at": createdAt!.toIso8601String(),
      if (updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
      if (currentOrderId != null) "current_order_id": currentOrderId,
      if (order != null) "order": order!.toMap(),
    };
  }

  PatientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? dni,
    DateTime? birthDate,
    String? gender,
    String? phone,
    String? phone2,
    String? email,
    AddressModel? address,
    List<String>? specialties,
    List<String>? pathologies,
    String? protocolId,
    ProtocolModel? protocol,
    String? notes,
    String? createdBy,
    String? assignedTo,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentOrderId,
    OrderModel? order,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dni: dni ?? this.dni,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      email: email ?? this.email,
      address: address ?? this.address,
      specialties: specialties ?? this.specialties,
      pathologies: pathologies ?? this.pathologies,
      protocolId: protocolId ?? this.protocolId,
      protocol: protocol ?? this.protocol,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    dni,
    birthDate,
    gender,
    phone,
    phone2,
    email,
    address,
    specialties,
    pathologies,
    protocolId,
    protocol,
    notes,
    createdBy,
    assignedTo,
    status,
    createdAt,
    updatedAt,
    currentOrderId,
    order,
  ];
}
