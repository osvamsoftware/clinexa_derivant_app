import 'dart:convert';

import 'package:clinexa_derivant_app/data/models/pathology_model.dart';
import 'package:equatable/equatable.dart';

class SpecialtyModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PathologyModel> pathologies;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.pathologies,
  });

  /// 🔹 copyWith
  SpecialtyModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PathologyModel>? pathologies,
  }) {
    return SpecialtyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pathologies: pathologies ?? this.pathologies,
    );
  }

  /// 🔹 fromMap
  factory SpecialtyModel.fromMap(Map<String, dynamic> map) {
    return SpecialtyModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      pathologies: map['pathologies'] != null
          ? List<PathologyModel>.from(
              (map['pathologies'] as List).map(
                (x) => PathologyModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  /// 🔹 toMap
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'pathologies': pathologies.map((x) => x.toMap()).toList(),
  };

  /// 🔹 fromJson / toJson
  factory SpecialtyModel.fromJson(String source) =>
      SpecialtyModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
    pathologies,
  ];
}
