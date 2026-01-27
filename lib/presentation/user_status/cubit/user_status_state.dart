part of 'user_status_cubit.dart';

enum Status { initial, loading, success, error }

class SessionCheckState extends Equatable {
  final Status status;
  final UserStatusModel? userStatus;

  const SessionCheckState({this.status = Status.initial, this.userStatus});

  SessionCheckState copyWith({Status? status, UserStatusModel? userStatus}) {
    return SessionCheckState(
      status: status ?? this.status,
      userStatus: userStatus ?? this.userStatus,
    );
  }

  @override
  List<Object?> get props => [status, userStatus];
}
