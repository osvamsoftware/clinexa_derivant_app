import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthState());
  // ======================================================
  // 🔹 Inicializa sesión al abrir la app
  // ======================================================
  Future<void> initAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final prefs = SharedPrefsService.instance;

      final token = prefs.getString("auth_token");

      // 🔸 No hay token → usuario NO autenticado
      if (token == null) {
        emit(
          state.copyWith(initialized: true, status: AuthStatus.unauthenticated),
        );
        return;
      }

      // 🔸 Sí hay token → intentar obtener /me
      final user = await authRepository.me();

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
    emit(state.copyWith(user: user, status: AuthStatus.authenticated));
  }

  // ======================================================
  // 🔹 Refresh manual
  // ======================================================
  Future<void> refreshSession() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final prefs = SharedPrefsService.instance;

      final refreshToken = prefs.getString("refresh_token");

      if (refreshToken == null) {
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
    final prefs = SharedPrefsService.instance;

    await prefs.remove("auth_token");
    await prefs.remove("refresh_token");

    emit(
      AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        initialized: true,
      ),
    );
  }
}
