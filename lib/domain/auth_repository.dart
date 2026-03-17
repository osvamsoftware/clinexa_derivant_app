import 'dart:developer';
import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required UserModel user,
    required String password,
  });

  Future<UserModel> me();

  Future<Map<String, dynamic>> refresh({required String refreshToken});

  // Password Recovery
  Future<void> requestPasswordReset(String email);
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  Future<bool> checkEmailExists(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService = ApiService();
  final Api api;

  AuthRepositoryImpl(this.api);

  // =============================================================
  // 🔹 LOGIN
  // =============================================================
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      log("📩 LOGIN REQUEST → email: $email");

      final response = await apiService.request<Map<String, dynamic>>(
        path: api.login,
        method: HttpMethod.post,
        body: {"email": email, "password": password},
        fromJson: (json) => json,
      );

      log("✅ LOGIN RESPONSE → ${response.data}");

      final prefs = SharedPrefsService.instance;

      await prefs.setString("auth_token", response.data?["auth_token"]);
      await prefs.setString("refresh_token", response.data?["refresh_token"]);

      apiService.setTokens(
        accessToken: response.data?["auth_token"],
        refreshToken: response.data?["refresh_token"],
      );

      return UserModel.fromMap(response.data?["user"]);
    } catch (e, stack) {
      log("❌ LOGIN ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 REGISTER
  // =============================================================
  @override
  Future<UserModel> register({
    required UserModel user,
    required String password,
  }) async {
    try {
      log("📩 REGISTER REQUEST → ${user.toMap()}");
      final requestBody = {"user": user.toMap(), "password": password};
      print(requestBody);

      final response = await apiService.request<Map<String, dynamic>>(
        path: api.register,
        method: HttpMethod.post,
        body: requestBody,
        fromJson: (json) => json,
      );

      log("✅ REGISTER RESPONSE → ${response.data}");

      return UserModel.fromMap(response.data ?? {});
    } catch (e, stack) {
      log("❌ REGISTER ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 ME
  // =============================================================
  @override
  Future<UserModel> me() async {
    try {
      log("📩 ME REQUEST");

      final response = await apiService.request<Map<String, dynamic>>(
        path: api.me,
        method: HttpMethod.get,
        fromJson: (json) => json,
        withAuth: true,
      );

      log("✅ ME RESPONSE → ${response.data}");

      final prefs = SharedPrefsService.instance;

      if (response.data?["new_token"] != null) {
        log("🔄 NEW ACCESS TOKEN RECEIVED → ${response.data?["new_token"]}");

        await prefs.setString("auth_token", response.data?["new_token"]);
        apiService.setTokens(
          accessToken: response.data?["new_token"],
          refreshToken: prefs.getString("refresh_token") ?? "",
        );
      }

      return UserModel.fromMap(response.data ?? {});
    } catch (e, stack) {
      log("❌ ME ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 REFRESH TOKEN
  // =============================================================
  @override
  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    try {
      log("🔄 REFRESH TOKEN REQUEST → $refreshToken");

      final response = await apiService.request<Map<String, dynamic>>(
        path: api.refresh,
        method: HttpMethod.post,
        body: {"refresh_token": refreshToken},
        fromJson: (json) => json,
      );

      log("✅ REFRESH RESPONSE → ${response.data}");

      return response.data ?? {};
    } catch (e, stack) {
      log("❌ REFRESH TOKEN ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 PASSWORD RECOVERY
  // =============================================================
  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      log("📩 PASSWORD RECOVERY REQUEST → email: $email");

      await apiService.request<Map<String, dynamic>>(
        path: api.passwordRecovery,
        method: HttpMethod.post,
        body: {"email": email},
        fromJson: (json) => json,
      );

      log("✅ PASSWORD RECOVERY SENT");
    } catch (e, stack) {
      log("❌ PASSWORD RECOVERY ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      log("📩 CONFIRM PASSWORD RESET REQUEST");

      await FirebaseAuth.instance.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );

      log("✅ PASSWORD RESET CONFIRMED");
    } catch (e, stack) {
      log("❌ CONFIRM PASSWORD RESET ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 CHECK EMAIL
  // =============================================================
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      log("📩 CHECK EMAIL REQUEST → email: $email");

      final response = await apiService.request<Map<String, dynamic>>(
        path: api.checkEmail,
        method: HttpMethod.post,
        body: {"email": email},
        fromJson: (json) => json,
      );

      log("✅ CHECK EMAIL RESPONSE → ${response.data}");
      return response.data?["exists"] ?? false;
    } catch (e, stack) {
      log("❌ CHECK EMAIL ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }
}
