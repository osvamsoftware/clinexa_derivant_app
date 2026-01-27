import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  final String oobCode;

  ResetPasswordCubit(this._authRepository, {required this.oobCode})
    : super(const ResetPasswordState());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    // Check if passwords match
    if (newPasswordController.text != confirmPasswordController.text) {
      // Ideally should be handled by validator but as a safety check:
      emit(
        state.copyWith(
          status: ResetPasswordStatus.error,
          errorMessage:
              "Passwords do not match", // Use l10n key in UI validator actually
        ),
      );
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.loading));

    try {
      await _authRepository.confirmPasswordReset(
        code: oobCode,
        newPassword: newPasswordController.text,
      );
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
