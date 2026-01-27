part of 'login_cubit.dart';

enum Status { initial, loading, success, error }

class AuthLoginState {
  final Status status;
  final String? errorMessage;

  AuthLoginState({this.status = Status.initial, this.errorMessage});

  AuthLoginState copyWith({Status? status, String? errorMessage}) {
    return AuthLoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
