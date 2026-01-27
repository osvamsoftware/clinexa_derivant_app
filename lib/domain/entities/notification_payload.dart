import 'package:equatable/equatable.dart';

class NotificationPayload extends Equatable {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;

  const NotificationPayload({this.title, this.body, this.data});

  @override
  List<Object?> get props => [title, body, data];
}
