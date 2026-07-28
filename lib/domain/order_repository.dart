import 'package:clinexa_derivant_app/core/services/secure_token_storage.dart';
import 'dart:developer';
import 'dart:io';

import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract interface class OrderRepository {
  Future<OrderModel?> getOrderByPatientId(String patientId);
  Future<OrderModel> rejectOrder(String orderId, {List<File>? proofDocuments});
}

class OrderRepositoryImpl implements OrderRepository {
  final ApiService apiService = ApiService();
  final Api api;

  OrderRepositoryImpl(this.api);

  @override
  Future<OrderModel?> getOrderByPatientId(String patientId) async {
    try {
      log("📩 GET ORDER BY PATIENT ID REQUEST → $patientId");

      final response = await apiService.request<OrderModel>(
        path: "${api.orders}/patient/$patientId",
        method: HttpMethod.get,
        fromJson: (json) => OrderModel.fromMap(json),
      );

      log("✅ GET ORDER RESPONSE → ${response.data}");

      return response.data;
    } catch (e, stack) {
      log("❌ GET ORDER BY PATIENT ID ERROR", error: e, stackTrace: stack);
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<OrderModel> rejectOrder(
    String orderId, {
    List<File>? proofDocuments,
  }) async {
    try {
      log("📩 REJECT ORDER REQUEST → $orderId");

      final token = await SecureTokenStorage().readAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No hay token de autenticación disponible");
      }

      final uri = Uri.parse("${api.baseUrl}/orders/$orderId/reject");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      if (proofDocuments != null && proofDocuments.isNotEmpty) {
        for (var file in proofDocuments) {
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );
        }
        log("📎 Adjuntando ${proofDocuments.length} documentos");
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log("✅ REJECT ORDER RESPONSE [${response.statusCode}]");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return OrderModel.fromMap(jsonResponse);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['detail'] ?? 'Error al rechazar la orden';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      log("❌ REJECT ORDER ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }
}
