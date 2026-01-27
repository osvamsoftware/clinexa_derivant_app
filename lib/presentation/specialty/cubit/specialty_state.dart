part of 'specialty_cubit.dart';

enum SpecialtyStatus { initial, loading, success, error }

class SpecialtyState extends Equatable {
  final SpecialtyStatus status;
  final List<SpecialtyModel> specialties;
  final String? errorMessage;
  final int page;
  final bool hasMore;
  final List<SpecialtyModel> filteredSpecialties;

  final bool deleting;

  const SpecialtyState({
    this.status = SpecialtyStatus.initial,
    this.specialties = const [],
    this.errorMessage,
    this.page = 1,
    this.hasMore = false,
    this.deleting = false,
    this.filteredSpecialties = const [],
  });

  SpecialtyState copyWith({
    SpecialtyStatus? status,
    List<SpecialtyModel>? specialties,
    String? errorMessage,
    int? page,
    bool? hasMore,
    bool? deleting,
    List<SpecialtyModel>? filteredSpecialties,
  }) {
    return SpecialtyState(
      status: status ?? this.status,
      specialties: specialties ?? this.specialties,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      deleting: deleting ?? this.deleting,
      filteredSpecialties: filteredSpecialties ?? this.filteredSpecialties,
    );
  }

  @override
  List<Object?> get props => [
    status,
    specialties,
    errorMessage,
    page,
    hasMore,
    deleting,
    filteredSpecialties,
  ];
}
