import 'package:clinexa_derivant_app/core/services/secure_token_storage.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final NotificationService _notificationService;

  AuthCubit(this.authRepository, this._notificationService)
    : super(AuthState());
  // ======================================================
  // 🔹 Inicializa sesión al abrir la app
  // ======================================================
  Future<void> initAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // El token vive en el Keychain/Keystore, no en SharedPreferences.
      final token = await SecureTokenStorage().readAccessToken();

      // 🔸 No hay token → usuario NO autenticado
      if (token == null || token.isEmpty) {
        emit(
          state.copyWith(initialized: true, status: AuthStatus.unauthenticated),
        );
        return;
      }

      // 🔸 Sí hay token → intentar obtener /me
      final user = await authRepository.me();

      // 🔥 Registrar dispositivo al encontrar sesión válida
      await _notificationService.registerDevice();

      emit(
        state.copyWith(
          user: user,
          initialized: true,
          status: AuthStatus.authenticated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          initialized: true,
          status: AuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ======================================================
  // 🔹 Guardar usuario después del login
  // ======================================================
  Future<void> setUser(UserModel user) async {
    // 🔥 Registrar dispositivo al iniciar sesión
    await _notificationService.registerDevice();
    emit(state.copyWith(user: user, status: AuthStatus.authenticated));
  }

  // ======================================================
  // 🔹 Refresh manual
  // ======================================================
  Future<void> refreshSession() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final refreshToken = await SecureTokenStorage().readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: "No refresh token found.",
          ),
        );
        return;
      }

      await authRepository.refresh(refreshToken: refreshToken);

      final user = await authRepository.me();

      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  //=======================
  // update/refresh get user information
  //=======================
  Future<void> updateAuthUser() async {
    try {
      final user = await authRepository.me();

      emit(state.copyWith(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // ======================================================
  // 🔹 Logout
  // ======================================================
  Future<void> logout() async {
    // 🔥 Eliminar token del backend antes de limpiar sesión local
    await _notificationService.unsubscribe();

    // Borra los tokens del Keychain/Keystore y cualquier resto de la
    // versión anterior que los guardaba sin cifrar.
    await ApiService().clearTokens();

    emit(
      AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        initialized: true,
      ),
    );
  }
}
