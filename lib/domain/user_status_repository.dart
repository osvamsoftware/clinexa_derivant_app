import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/user_status_model.dart';

abstract interface class UserStatusRepository {
  Future<UserStatusModel> getStatusById(String userId);
}

class UserStatusRepositoryImpl implements UserStatusRepository {
  final ApiService _api = ApiService();
  final Api api;

  UserStatusRepositoryImpl(this.api);

  @override
  Future<UserStatusModel> getStatusById(String userId) async {
    try {
      final response = await _api.request(
        path: "${api.user}/$userId/status",
        method: HttpMethod.get,
        fromJson: (response) => response,
        withAuth: true,
      );

      return UserStatusModel.fromMap(response.data!);
    } catch (e) {
      print("❌ Error en UserStatusRepositoryImpl.getStatusById: $e");
      rethrow;
    }
  }
}
