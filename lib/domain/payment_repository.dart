import 'dart:developer';

import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';

abstract interface class PaymentRepository {
  Future<Map<String, dynamic>> createPaymentIntent(
    String patientId,
    String paymentStage,
  );
  Future<Map<String, dynamic>> processPayment(String paymentIntentId);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiService apiService = ApiService();
  final Api api;

  PaymentRepositoryImpl(this.api);

  @override
  Future<Map<String, dynamic>> createPaymentIntent(
    String patientId,
    String paymentStage,
  ) async {
    try {
      log(
        "📩 CREATE PAYMENT INTENT REQUEST → PatientId: $patientId, Stage: $paymentStage",
      );

      final response = await apiService.request<dynamic>(
        path: "${api.payments}/create-payment-intent",
        method: HttpMethod.post,
        body: {"patient_id": patientId, "payment_stage": paymentStage},
        fromJson: (json) => json,
      );

      log("✅ CREATE PAYMENT INTENT RESPONSE → ${response.data}");

      if (response.data == null) {
        throw Exception("Error creando payment intent: Response data is null");
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      log("❌ CREATE PAYMENT INTENT ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> processPayment(String paymentIntentId) async {
    try {
      log("📩 PROCESS PAYMENT REQUEST → PaymentIntentId: $paymentIntentId");

      final response = await apiService.request<dynamic>(
        path: "${api.payments}/process-payment/$paymentIntentId",
        method: HttpMethod.post,
        fromJson: (json) => json,
      );

      log("✅ PROCESS PAYMENT RESPONSE → ${response.data}");

      if (response.data == null) {
        throw Exception("Error procesando pago: Response data is null");
      }

      final result = response.data as Map<String, dynamic>;

      // Determinar el mensaje según el payment_stage
      final paymentStage = result['payment_stage'] ?? '';
      String successMessage;

      if (paymentStage == 'initial') {
        successMessage =
            "Pago inicial procesado. Ahora puede ver los datos completos del paciente.";
      } else if (paymentStage == 'full') {
        successMessage =
            "Pago final procesado. Paciente aceptado en el tratamiento.";
      } else {
        successMessage = "Pago procesado correctamente.";
      }

      result['success_message'] = successMessage;

      return result;
    } catch (e, stack) {
      log("❌ PROCESS PAYMENT ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }
}
