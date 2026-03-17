import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:equatable/equatable.dart';

part 'phone_verification_state.dart';

class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  final PatientRepository _repository;
  Timer? _resendTimer;
  Timer? _fetchCodeCountdownTimer;

  PhoneVerificationCubit(this._repository)
    : super(const PhoneVerificationState());

  void setPhoneNumber(String phone, String countryCode) {
    emit(state.copyWith(phoneNumber: phone, countryCode: countryCode));
  }

  Future<void> sendVerificationCode() async {
    if (state.phoneNumber == null || state.phoneNumber!.isEmpty) {
      emit(
        state.copyWith(
          status: PhoneVerificationStatus.error,
          errorMessage: 'Por favor ingrese un número de teléfono',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PhoneVerificationStatus.sendingCode));

    try {
      final fullPhone = '${state.countryCode}${state.phoneNumber}';
      await _repository.sendVerificationCode(fullPhone);

      emit(
        state.copyWith(
          status: PhoneVerificationStatus.codeSent,
          canResendCode: false,
          resendTimer: 60,
        ),
      );

      _startResendTimer();
      _fetchExpectedCode(fullPhone);
    } catch (e) {
      emit(
        state.copyWith(
          status: PhoneVerificationStatus.error,
          errorMessage: 'Error al enviar código: ${e.toString()}',
        ),
      );
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendTimer > 0) {
        emit(state.copyWith(resendTimer: state.resendTimer - 1));
      } else {
        emit(state.copyWith(canResendCode: true));
        timer.cancel();
      }
    });
  }

  Future<void> _fetchExpectedCode(String fullPhone) async {
    // Reset expected code and set timer to 3 seconds
    emit(state.copyWith(fetchCodeTimer: 3, expectedCode: null));
    
    _fetchCodeCountdownTimer?.cancel();
    _fetchCodeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.fetchCodeTimer > 1) {
        emit(state.copyWith(fetchCodeTimer: state.fetchCodeTimer - 1));
      } else {
        timer.cancel();
        emit(state.copyWith(fetchCodeTimer: 0));
        
        try {
          final code = await _repository.getExpectedCode(fullPhone);
          if (code != null) {
            emit(state.copyWith(expectedCode: code));
          }
        } catch (e) {
          // Ignorar el error para que siga el flujo normal de la app
        }
      }
    });
  }

  Future<void> verifyCode(String code) async {
    if (code.length != 6) {
      emit(
        state.copyWith(
          status: PhoneVerificationStatus.error,
          errorMessage: 'El código debe tener 6 dígitos',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PhoneVerificationStatus.verifying));

    try {
      final fullPhone = '${state.countryCode}${state.phoneNumber}';
      final isValid = await _repository.verifyCode(fullPhone, code);

      if (isValid) {
        emit(state.copyWith(status: PhoneVerificationStatus.verified));
      } else {
        emit(
          state.copyWith(
            status: PhoneVerificationStatus.error,
            errorMessage: 'Código incorrecto. Intente nuevamente.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PhoneVerificationStatus.error,
          errorMessage: 'Error al verificar código: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _fetchCodeCountdownTimer?.cancel();
    return super.close();
  }
}
