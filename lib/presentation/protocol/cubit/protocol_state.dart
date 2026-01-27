import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:equatable/equatable.dart';

enum ProtocolStatus { initial, loading, success, failure }

class ProtocolState extends Equatable {
  final ProtocolStatus status;
  final List<ProtocolModel> protocols;
  final String? errorMessage;
  final bool hasReachedMax;
  final int page;

  // Filters
  final List<String>
  selectedUseIds; // specialties IDs (using name from prompt 'specialties')
  final List<String> selectedPathologyIds;

  const ProtocolState({
    this.status = ProtocolStatus.initial,
    this.protocols = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.page = 1,
    this.selectedUseIds = const [],
    this.selectedPathologyIds = const [],
  });

  ProtocolState copyWith({
    ProtocolStatus? status,
    List<ProtocolModel>? protocols,
    String? errorMessage,
    bool? hasReachedMax,
    int? page,
    List<String>? selectedUseIds,
    List<String>? selectedPathologyIds,
  }) {
    return ProtocolState(
      status: status ?? this.status,
      protocols: protocols ?? this.protocols,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      selectedUseIds: selectedUseIds ?? this.selectedUseIds,
      selectedPathologyIds: selectedPathologyIds ?? this.selectedPathologyIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    protocols,
    errorMessage,
    hasReachedMax,
    page,
    selectedUseIds,
    selectedPathologyIds,
  ];
}
