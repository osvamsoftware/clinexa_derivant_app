import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/repositories/notification_repository.dart';
import 'package:clinexa_derivant_app/presentation/notifications/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;
  final int _limit = 20;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  Future<void> fetchNotifications(String userId, {bool refresh = false}) async {
    if (state.hasReachedMax && !refresh) return;

    try {
      if (state.status == NotificationsStatus.initial || refresh) {
        emit(
          state.copyWith(
            status: NotificationsStatus.loading,
            notifications: refresh ? [] : state.notifications,
            hasReachedMax: false,
            page: 1,
          ),
        );
      }

      final skip = refresh ? 0 : state.notifications.length;

      final response = await _repository.getNotifications(
        userId,
        limit: _limit,
        skip: skip,
      );

      final newNotifications = response.items ?? [];
      final total = response.total ?? 0;

      final hasReachedMax =
          newNotifications.isEmpty || newNotifications.length < _limit;

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: refresh
              ? newNotifications
              : [...state.notifications, ...newNotifications],
          hasReachedMax: hasReachedMax,
          page: state.page + 1,
          totalCount: total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      if (success) {
        final updatedList = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        emit(state.copyWith(notifications: updatedList));
      }
    } catch (e) {
      // Si falla, podrías manejar el error, pero por ahora solo lo registramos o ignoramos
    }
  }
}
