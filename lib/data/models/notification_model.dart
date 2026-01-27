import 'package:clinexa_derivant_app/domain/entities/notification_payload.dart';

class NotificationModel extends NotificationPayload {
  const NotificationModel({super.title, super.body, super.data});

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['notification']?['title'] ?? map['title'],
      body: map['notification']?['body'] ?? map['body'],
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : map,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': body, 'data': data};
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
    );
  }
}
