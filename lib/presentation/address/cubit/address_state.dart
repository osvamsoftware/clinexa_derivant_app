part of 'address_cubit.dart';

enum Status { initial, loading, success, error }

class AddressState {
  final Status status;
  final List<AddressSuggestion> suggestions;
  final AddressModel? selectedAddress;
  final String? errorMessage;

  AddressState({
    this.status = Status.initial,
    this.suggestions = const [],
    this.selectedAddress,
    this.errorMessage,
  });

  AddressState copyWith({
    Status? status,
    List<AddressSuggestion>? suggestions,
    AddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    String? errorMessage,
  }) {
    return AddressState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
