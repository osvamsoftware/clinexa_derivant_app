import 'dart:convert';

import 'package:clinexa_derivant_app/data/models/criterion_model.dart';
import 'package:clinexa_derivant_app/data/models/pathology_model.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';

/// =============================================================
/// 🔹 Enum para status del protocolo
/// =============================================================
enum ProtocolStatus {
  active,
  inactive,
  unknown;

  static ProtocolStatus fromString(String status) {
    switch (status) {
      case 'active':
        return ProtocolStatus.active;
      case 'inactive':
        return ProtocolStatus.inactive;
      default:
        return ProtocolStatus.unknown;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ProtocolStatus.active:
        return 'active';
      case ProtocolStatus.inactive:
        return 'inactive';
      case ProtocolStatus.unknown:
        return 'unknown';
    }
  }
}

/// =============================================================
/// 🔹 Modelo principal: ProtocolModel
/// =============================================================
class ProtocolModel {
  final String? id;
  final String name;
  final String description;
  final List<SpecialtyModel> specialties;
  final List<PathologyModel> pathologies;
  final List<CriterionModel> criteria;
  final ProtocolStatus status;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProtocolModel({
    this.id,
    required this.name,
    required this.description,
    required this.specialties,
    required this.pathologies,
    required this.criteria,
    required this.status,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// =============================================================
  /// 🔹 copyWith
  /// =============================================================
  ProtocolModel copyWith({
    String? id,
    String? name,
    String? description,
    List<SpecialtyModel>? specialties,
    List<PathologyModel>? pathologies,
    List<CriterionModel>? criteria,
    ProtocolStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProtocolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      specialties: specialties ?? this.specialties,
      pathologies: pathologies ?? this.pathologies,
      criteria: criteria ?? this.criteria,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// =============================================================
  /// 🔹 fromMap
  /// =============================================================
  factory ProtocolModel.fromMap(Map<String, dynamic> map) {
    return ProtocolModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      specialties: map['specialties'] != null
          ? List<SpecialtyModel>.from(
              (map['specialties'] as List).map(
                (x) => SpecialtyModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      pathologies: map['pathologies'] != null
          ? List<PathologyModel>.from(
              (map['pathologies'] as List).map(
                (x) => PathologyModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      criteria: map['criteria'] != null
          ? List<CriterionModel>.from(
              (map['criteria'] as List).map(
                (x) => CriterionModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      status: ProtocolStatus.fromString(map['status'] ?? 'unknown'),
      createdBy: map['created_by'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// =============================================================
  /// 🔹 toMap
  /// =============================================================
  Map<String, dynamic> toMap() => {
    '_id': id,
    'name': name,
    'description': description,
    'specialties': specialties.map((x) => x.toMap()).toList(),
    'pathologies': pathologies.map((x) => x.toMap()).toList(),
    'criteria': criteria.map((x) => x.toMap()).toList(),
    'status': status.toString(),
    'created_by': createdBy,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  /// =============================================================
  /// 🔹 JSON methods
  /// =============================================================
  factory ProtocolModel.fromJson(String source) =>
      ProtocolModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
