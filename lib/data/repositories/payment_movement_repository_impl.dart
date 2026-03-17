import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/payment_movement_model.dart';
import 'package:clinexa_derivant_app/domain/payment_movement_repository.dart';

class PaymentMovementRepositoryImpl implements PaymentMovementRepository {
  final Api api;
  //implement api service
  final ApiService _apiService = ApiService();
  PaymentMovementRepositoryImpl({required this.api});

  @override
  Future<ApiResponseModel<List<PaymentMovementModel>>>
  getPaymentMovementByOrder(String orderId) async {
    try {
      final response = await _apiService.requestList<PaymentMovementModel>(
        path: api.getPaymentMovementsByOrder(orderId),
        fromJson: (json) => PaymentMovementModel.fromMap(json),
      );

      return response;
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        // Not found, return successful response with empty list
        return const ApiResponseModel(
          data: [],
          statusCode: 404,
          message: "No movement found",
        );
      }
      return ApiResponseModel(statusCode: 500, message: e.toString());
    }
  }
}
