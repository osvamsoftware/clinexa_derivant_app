import 'dart:developer';

import 'package:clinexa_derivant_app/domain/payment_repository.dart';
import 'package:clinexa_derivant_app/presentation/payment/cubit/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentCubit({required this.paymentRepository}) : super(const PaymentState());

  Future<void> initiatePayment(String patientId, String paymentStage) async {
    try {
      emit(state.copyWith(status: PaymentStatus.creatingIntent));

      log("💳 Iniciando pago para paciente: $patientId, stage: $paymentStage");

      final result = await paymentRepository.createPaymentIntent(
        patientId,
        paymentStage,
      );

      final paymentIntentId = result['payment_intent_id'] as String?;
      final clientSecret = result['payment_intent_client_secret'] as String?;

      if (paymentIntentId == null || clientSecret == null) {
        throw Exception("Payment intent ID o client secret no disponibles");
      }

      log("✅ Payment intent creado: $paymentIntentId");

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          paymentIntentId: paymentIntentId,
          clientSecret: clientSecret,
        ),
      );
    } catch (e, stack) {
      log("❌ Error creando payment intent", error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> processPayment(String paymentIntentId) async {
    try {
      emit(state.copyWith(status: PaymentStatus.processing));

      log("💰 Procesando pago: $paymentIntentId");

      final result = await paymentRepository.processPayment(paymentIntentId);

      final successMessage =
          result['success_message'] as String? ??
          "Pago procesado correctamente";

      log("✅ Pago procesado: $successMessage");

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          successMessage: successMessage,
        ),
      );
    } catch (e, stack) {
      log("❌ Error procesando pago", error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const PaymentState());
  }
}
