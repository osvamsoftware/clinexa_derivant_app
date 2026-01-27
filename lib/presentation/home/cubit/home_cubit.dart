import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final NotificationService _notificationService;

  HomeCubit(this._notificationService) : super(const HomeState());

  Future<void> init() async {
    try {
      emit(state.copyWith(status: HomeStatus.loading));

      // Registrar dispositivo para notificaciones push
      await _notificationService.registerDevice();

      emit(state.copyWith(status: HomeStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
