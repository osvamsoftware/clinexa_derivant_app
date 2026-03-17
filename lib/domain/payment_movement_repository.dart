import 'package:clinexa_derivant_app/data/models/payment_movement_model.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';

abstract class PaymentMovementRepository {
  Future<ApiResponseModel<List<PaymentMovementModel>>>
  getPaymentMovementByOrder(String orderId);
}
