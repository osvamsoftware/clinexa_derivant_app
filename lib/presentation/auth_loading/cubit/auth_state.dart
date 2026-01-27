part of 'auth_cubit.dart';

//auth state enum
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final UserModel? user;
  final AuthStatus status;
  final String? errorMessage;
  final bool initialized;

  AuthState({
    this.user,
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.initialized = false,
  });

  AuthState copyWith({
    UserModel? user,
    AuthStatus? status,
    String? errorMessage,
    bool? initialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage,
      initialized: initialized ?? this.initialized,
    );
  }
}
