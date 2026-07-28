import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:equatable/equatable.dart';

part 'phone_verification_state.dart';

class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  final PatientRepository _repository;
  Timer? _resendTimer;

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

  // ELIMINADO: _fetchExpectedCode()
  //
  // Consultaba el código al servidor para mostrarlo en pantalla. El endpoint
  // que lo servía devolvía el OTP de cualquier teléfono sin autenticación:
  // se eliminó del backend. El código solo llega por WhatsApp.

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
    return super.close();
  }
}
