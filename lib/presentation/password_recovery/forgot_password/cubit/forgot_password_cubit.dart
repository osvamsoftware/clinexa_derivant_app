import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordState());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    try {
      await _authRepository.requestPasswordReset(emailController.text.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
