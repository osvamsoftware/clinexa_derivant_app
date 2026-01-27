part of 'pathology_cubit.dart';

enum PathologyStatus { initial, loading, success, error }

class PathologyState extends Equatable {
  final PathologyStatus status;
  final List<PathologyModel> pathologies;
  final String? errorMessage;
  final int page;
  final bool hasMore;
  final List<PathologyModel> filteredPathologies;

  final bool deleting;

  const PathologyState({
    this.status = PathologyStatus.initial,
    this.pathologies = const [],
    this.errorMessage,
    this.page = 1,
    this.hasMore = false,
    this.deleting = false,
    this.filteredPathologies = const [],
  });

  PathologyState copyWith({
    PathologyStatus? status,
    List<PathologyModel>? pathologies,
    String? errorMessage,
    int? page,
    bool? hasMore,
    bool? deleting,
    List<PathologyModel>? filteredPathologies,
  }) {
    return PathologyState(
      status: status ?? this.status,
      pathologies: pathologies ?? this.pathologies,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      deleting: deleting ?? this.deleting,
      filteredPathologies: filteredPathologies ?? this.filteredPathologies,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pathologies,
    errorMessage,
    page,
    hasMore,
    deleting,
    filteredPathologies,
  ];
}
