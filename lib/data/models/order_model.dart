import 'package:equatable/equatable.dart';

enum OrderStatus {
  assigned,
  accepted,
  rejected;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return OrderStatus.assigned;
      case 'accepted':
        return OrderStatus.accepted;
      case 'rejected':
        return OrderStatus.rejected;
      default:
        throw ArgumentError('Estado de orden desconocido: $status');
    }
  }

  String toJson() {
    return name;
  }
}

class OrderModel extends Equatable {
  final String? id;
  final OrderStatus status;
  final double amount;
  final String paymentStage;
  final List<String> outcomeDocumentUrls;
  final DateTime? outcomeDate;
  final String? initialPaymentId;
  final String? finalPaymentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;

  const OrderModel({
    this.id,
    required this.status,
    required this.amount,
    required this.paymentStage,
    this.outcomeDocumentUrls = const [],
    this.outcomeDate,
    this.initialPaymentId,
    this.finalPaymentId,
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory OrderModel.fromMap(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'],
      status: OrderStatus.fromString(json['status'] ?? 'assigned'),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStage: json['payment_stage'] ?? 'initial',
      outcomeDocumentUrls: List<String>.from(
        json['outcome_document_urls'] ?? [],
      ),
      outcomeDate: json['outcome_date'] != null
          ? DateTime.tryParse(json['outcome_date'])
          : null,
      initialPaymentId: json['initial_payment_id'],
      finalPaymentId: json['final_payment_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'status': status.toJson(),
      'amount': amount,
      'payment_stage': paymentStage,
      'outcome_document_urls': outcomeDocumentUrls,
      if (outcomeDate != null) 'outcome_date': outcomeDate!.toIso8601String(),
      if (initialPaymentId != null) 'initial_payment_id': initialPaymentId,
      if (finalPaymentId != null) 'final_payment_id': finalPaymentId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? id,
    OrderStatus? status,
    double? amount,
    String? paymentStage,
    List<String>? outcomeDocumentUrls,
    DateTime? outcomeDate,
    String? initialPaymentId,
    String? finalPaymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentStage: paymentStage ?? this.paymentStage,
      outcomeDocumentUrls: outcomeDocumentUrls ?? this.outcomeDocumentUrls,
      outcomeDate: outcomeDate ?? this.outcomeDate,
      initialPaymentId: initialPaymentId ?? this.initialPaymentId,
      finalPaymentId: finalPaymentId ?? this.finalPaymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    amount,
    paymentStage,
    outcomeDocumentUrls,
    outcomeDate,
    initialPaymentId,
    finalPaymentId,
    createdAt,
    updatedAt,
    notes,
  ];
}
