import 'dart:convert';
import 'package:equatable/equatable.dart';

class PaymentMovementModel extends Equatable {
  final String id;
  final String paymentIntentId;
  final String movementType;
  final String status;
  final double amount;
  final String currency;
  final String? patientId;
  final String? protocolId;
  final String? receptorId;
  final String? orderId;
  final DateTime createdAt;

  const PaymentMovementModel({
    required this.id,
    required this.paymentIntentId,
    required this.movementType,
    required this.status,
    required this.amount,
    required this.currency,
    this.patientId,
    this.protocolId,
    this.receptorId,
    this.orderId,
    required this.createdAt,
  });

  PaymentMovementModel copyWith({
    String? id,
    String? paymentIntentId,
    String? movementType,
    String? status,
    double? amount,
    String? currency,
    String? patientId,
    String? protocolId,
    String? receptorId,
    String? orderId,
    DateTime? createdAt,
  }) {
    return PaymentMovementModel(
      id: id ?? this.id,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      movementType: movementType ?? this.movementType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      patientId: patientId ?? this.patientId,
      protocolId: protocolId ?? this.protocolId,
      receptorId: receptorId ?? this.receptorId,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'payment_intent_id': paymentIntentId,
      'movement_type': movementType,
      'status': status,
      'amount': amount,
      'currency': currency,
      'patient_id': patientId,
      'protocol_id': protocolId,
      'receptor_id': receptorId,
      'order_id': orderId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PaymentMovementModel.fromMap(Map<String, dynamic> map) {
    return PaymentMovementModel(
      id: map['_id'] ?? '',
      paymentIntentId: map['payment_intent_id'] ?? '',
      movementType: map['movement_type'] ?? '',
      status: map['status'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? '',
      patientId: map['patient_id'],
      protocolId: map['protocol_id'],
      receptorId: map['receptor_id'],
      orderId: map['order_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentMovementModel.fromJson(String source) =>
      PaymentMovementModel.fromMap(json.decode(source));

  @override
  List<Object?> get props {
    return [
      id,
      paymentIntentId,
      movementType,
      status,
      amount,
      currency,
      patientId,
      protocolId,
      receptorId,
      orderId,
      createdAt,
    ];
  }
}
