import 'package:equatable/equatable.dart';

class ApiResponseModel<T> extends Equatable {
  final T? data;
  final List<T>? items;

  final int? total;
  final int? page;
  final int? limit;
  final int? pages;
  final String? message;
  final int? statusCode;

  const ApiResponseModel({
    this.data,
    this.items,
    this.total,
    this.page,
    this.limit,
    this.message,
    this.statusCode,
    this.pages,
  });

  // ============================================================
  // 🔹 SINGLE (cuando la API devuelve un solo objeto)
  // ============================================================
  factory ApiResponseModel.single(T data, String? message, int statusCode) {
    return ApiResponseModel(
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  // ============================================================
  // 🔹 LIST (cuando la API devuelve lista paginada)
  // ============================================================
  factory ApiResponseModel.list(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson, {
    String? message,
    int? statusCode,
  }) {
    final itemsJson = json["items"] as List? ?? [];
    final itemsList = itemsJson.map((e) => fromJson(e)).toList();

    return ApiResponseModel(
      items: itemsList,
      total: json["total"],
      page: json["page"],
      limit: json["limit"],
      message: message ?? json["message"],
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [
    data,
    items,
    total,
    page,
    limit,
    message,
    statusCode,
  ];
}
