import 'package:clinexa_derivant_app/data/models/order_model.dart';
import 'package:equatable/equatable.dart';

enum OrderCubitStatus { initial, loading, success, failure }

class OrderState extends Equatable {
  final OrderCubitStatus status;
  final OrderModel? order;
  final String? errorMessage;

  const OrderState({
    this.status = OrderCubitStatus.initial,
    this.order,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderCubitStatus? status,
    OrderModel? order,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
