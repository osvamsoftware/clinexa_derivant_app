import 'package:clinexa_derivant_app/data/models/payment_movement_model.dart';
import 'package:equatable/equatable.dart';

enum PaymentMovementStatus { initial, loading, success, failure }

class PaymentMovementState extends Equatable {
  final PaymentMovementStatus status;
  final List<PaymentMovementModel> paymentMovements;
  final String? errorMessage;

  const PaymentMovementState({
    this.status = PaymentMovementStatus.initial,
    this.paymentMovements = const [],
    this.errorMessage,
  });

  PaymentMovementState copyWith({
    PaymentMovementStatus? status,
    List<PaymentMovementModel>? paymentMovements,
    String? errorMessage,
  }) {
    return PaymentMovementState(
      status: status ?? this.status,
      paymentMovements: paymentMovements ?? this.paymentMovements,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paymentMovements, errorMessage];
}
