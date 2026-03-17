import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String typeNotification;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.typeNotification,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      typeNotification: map['type_notification'] ?? '',
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : {},
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type_notification': typeNotification,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return NotificationModel(
      id: data['_id'] ?? '',
      userId: data['user_id'] ?? '',
      title: message.notification?.title ?? data['title'] ?? '',
      body: message.notification?.body ?? data['body'] ?? '',
      typeNotification: data['type_notification'] ?? 'general',
      data: data,
      isRead: false,
      createdAt: message.sentTime ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? typeNotification,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      typeNotification: typeNotification ?? this.typeNotification,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    body,
    typeNotification,
    data,
    isRead,
    createdAt,
  ];
}
