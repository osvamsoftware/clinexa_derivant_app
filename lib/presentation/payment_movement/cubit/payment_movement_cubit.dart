import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/payment_movement_repository.dart';
import 'package:clinexa_derivant_app/presentation/payment_movement/cubit/payment_movement_state.dart';

class PaymentMovementCubit extends Cubit<PaymentMovementState> {
  final PaymentMovementRepository _repository;

  PaymentMovementCubit({required PaymentMovementRepository repository})
    : _repository = repository,
      super(const PaymentMovementState());

  Future<void> loadPaymentMovement(String orderId) async {
    emit(state.copyWith(status: PaymentMovementStatus.loading));

    final result = await _repository.getPaymentMovementByOrder(orderId);

    // Consider success if status 200, 201 or even 404 (meaning pending)
    if (result.statusCode == 200 || result.statusCode == 201) {
      emit(
        state.copyWith(
          status: PaymentMovementStatus.success,
          paymentMovements: result.data ?? [],
        ),
      );
    } else if (result.statusCode == 404) {
      // 404 handled as success with empty data (pending in backend logic usually returns empty list)
      emit(
        state.copyWith(
          status: PaymentMovementStatus.success,
          paymentMovements: [], // implies pending/empty
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: PaymentMovementStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
