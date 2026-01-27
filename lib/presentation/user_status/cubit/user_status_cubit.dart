import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/user_status_model.dart';
import 'package:clinexa_derivant_app/domain/user_status_repository.dart';
import 'package:equatable/equatable.dart';

part 'user_status_state.dart';

class SessionCheckCubit extends Cubit<SessionCheckState> {
  final UserStatusRepository repo;

  SessionCheckCubit(this.repo) : super(const SessionCheckState());

  Future<void> init(String userId) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final statusUser = await repo.getStatusById(userId);

      emit(state.copyWith(status: Status.success, userStatus: statusUser));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }
}
