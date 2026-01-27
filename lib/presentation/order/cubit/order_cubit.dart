import 'dart:developer';
import 'dart:io';

import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/presentation/order/cubit/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit({required this.orderRepository}) : super(const OrderState());

  Future<void> loadOrderForPatient(String patientId) async {
    try {
      emit(state.copyWith(status: OrderCubitStatus.loading));

      log("🔍 Buscando orden para paciente: $patientId");

      final order = await orderRepository.getOrderByPatientId(patientId);

      if (order == null) {
        log("ℹ️ No se encontró orden para el paciente");
        emit(state.copyWith(status: OrderCubitStatus.success, order: null));
      } else {
        log("✅ Orden cargada: ${order.id} - Status: ${order.status}");
        emit(state.copyWith(status: OrderCubitStatus.success, order: order));
      }
    } catch (e, stack) {
      log("❌ Error cargando orden", error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: OrderCubitStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> rejectOrder(String orderId, List<File>? documents) async {
    try {
      emit(state.copyWith(status: OrderCubitStatus.loading));

      log("🚫 Rechazando orden: $orderId");

      final updatedOrder = await orderRepository.rejectOrder(
        orderId,
        proofDocuments: documents,
      );

      log("✅ Orden rechazada correctamente: ${updatedOrder.id}");

      emit(
        state.copyWith(status: OrderCubitStatus.success, order: updatedOrder),
      );
    } catch (e, stack) {
      log("❌ Error rechazando orden", error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: OrderCubitStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const OrderState());
  }
}
