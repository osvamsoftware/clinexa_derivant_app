import 'package:equatable/equatable.dart';

class UserStatusModel extends Equatable {
  final List<String> missingRequiredFields;
  final bool profileCompleted;

  const UserStatusModel({
    this.missingRequiredFields = const [],
    this.profileCompleted = false,
  });

  // -------------------------------
  // fromMap
  // -------------------------------
  factory UserStatusModel.fromMap(Map<String, dynamic> map) {
    return UserStatusModel(
      missingRequiredFields: List<String>.from(
        map['missing_required_fields'] ?? [],
      ),
      profileCompleted: map['profile_completed'] ?? false,
    );
  }

  // -------------------------------
  // toMap
  // -------------------------------
  Map<String, dynamic> toMap() {
    return {
      'missing_required_fields': missingRequiredFields,
      'profile_completed': profileCompleted,
    };
  }

  // -------------------------------
  // copyWith
  // -------------------------------
  UserStatusModel copyWith({
    List<String>? missingRequiredFields,
    bool? profileCompleted,
  }) {
    return UserStatusModel(
      missingRequiredFields:
          missingRequiredFields ?? this.missingRequiredFields,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  // -------------------------------
  // toJson / fromJson
  // -------------------------------
  String toJson() => toMap().toString();

  @override
  List<Object?> get props => [missingRequiredFields, profileCompleted];
}
