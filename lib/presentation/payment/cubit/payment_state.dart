import 'package:equatable/equatable.dart';

enum PaymentStatus { initial, creatingIntent, processing, success, failure }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final String? paymentIntentId;
  final String? clientSecret;
  final String? successMessage;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.paymentIntentId,
    this.clientSecret,
    this.successMessage,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? paymentIntentId,
    String? clientSecret,
    String? successMessage,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      clientSecret: clientSecret ?? this.clientSecret,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    paymentIntentId,
    clientSecret,
    successMessage,
    errorMessage,
  ];
}
