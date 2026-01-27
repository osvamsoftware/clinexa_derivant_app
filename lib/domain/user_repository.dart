import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> createUser(UserModel user);

  Future<ApiResponseModel<UserModel>> getUsers({
    int page,
    int limit,
    String? query,
    String? role,
  });

  Future<UserModel> getUserById(String id);

  Future<UserModel> updateUser(UserModel user);

  Future<bool> deleteUser(String id);
}

class UserRepositoryImpl implements UserRepository {
  final ApiService _api = ApiService();
  final Api api;

  UserRepositoryImpl({required this.api});

  // ============================================================
  // 🔹 CREATE USER
  // ============================================================
  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _api.request(
        path: api.users,
        method: HttpMethod.post,
        body: user.toMap(),
        fromJson: (json) => UserModel.fromMap(json),
        withAuth: true,
      );

      return response.data!;
    } catch (e) {
      print("❌ [UserRepositoryImpl.createUser] $e");
      rethrow;
    }
  }

  // ============================================================
  // 🔹 GET USERS (paginated)
  // ============================================================
  @override
  Future<ApiResponseModel<UserModel>> getUsers({
    int page = 1,
    int limit = 10,
    String? query,
    String? role,
  }) async {
    try {
      final queryParams = {
        "page": page.toString(),
        "limit": limit.toString(),
        if (query != null && query.isNotEmpty) "query": query,
        if (role != null && role.isNotEmpty) "role": role,
      };

      final response = await _api.request(
        path: api.users,
        method: HttpMethod.get,
        query: queryParams,
        fromJson: (json) => UserModel.fromMap(json),
        withAuth: true,
      );

      return response;
    } catch (e) {
      print("❌ [UserRepositoryImpl.getUsers] $e");
      rethrow;
    }
  }

  // ============================================================
  // 🔹 GET BY ID
  // ============================================================
  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _api.request(
        path: "${api.users}/$id",
        method: HttpMethod.get,
        fromJson: (json) => UserModel.fromMap(json),
        withAuth: true,
      );

      return response.data!;
    } catch (e) {
      print("❌ [UserRepositoryImpl.getUserById] $e");
      rethrow;
    }
  }

  // ============================================================
  // 🔹 UPDATE USER
  // ============================================================
  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _api.request(
        path: "${api.users}/${user.id}",
        method: HttpMethod.put,
        body: user.toMap(),
        fromJson: (json) => UserModel.fromMap(json),
        withAuth: true,
      );

      return response.data!;
    } catch (e) {
      print("❌ [UserRepositoryImpl.updateUser] $e");
      rethrow;
    }
  }

  // ============================================================
  // 🔹 DELETE USER
  // ============================================================
  @override
  Future<bool> deleteUser(String id) async {
    try {
      await _api.request(
        path: "${api.users}/$id",
        method: HttpMethod.delete,
        fromJson: (_) =>
            UserModel(email: '', role: ''), // no importa, no devuelve body
        withAuth: true,
      );

      return true;
    } catch (e) {
      print("❌ [UserRepositoryImpl.deleteUser] $e");
      rethrow;
    }
  }
}
