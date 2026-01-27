import 'package:equatable/equatable.dart';

class PathologyModel extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PathologyModel({
    this.id,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PathologyModel.fromMap(Map<String, dynamic> map) {
    return PathologyModel(
      id: map['id'] ?? map['_id'],
      name: map['name'],
      description: map['description'],
      status: map['status'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'status': status};
  }

  String toJson() => toMap().toString();

  PathologyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PathologyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    createdAt,
    updatedAt,
  ];
}
