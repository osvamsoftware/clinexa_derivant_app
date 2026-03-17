import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/notification_model.dart';

abstract interface class NotificationRepository {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Future<void> saveToken(String token);
  Future<void> deleteToken();

  Future<ApiResponseModel<NotificationModel>> getNotifications(
    String userId, {
    int limit = 50,
    int skip = 0,
  });

  Future<bool> markAsRead(String notificationId);
}
