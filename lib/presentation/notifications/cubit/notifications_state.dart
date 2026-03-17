import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:equatable/equatable.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final bool hasReachedMax;
  final int page;
  final int totalCount;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const <NotificationModel>[],
    this.hasReachedMax = false,
    this.page = 1,
    this.totalCount = 0,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    bool? hasReachedMax,
    int? page,
    int? totalCount,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    hasReachedMax,
    page,
    totalCount,
    errorMessage,
  ];
}
