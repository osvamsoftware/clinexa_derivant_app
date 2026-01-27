import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class AuthLoginCubit extends Cubit<AuthLoginState> {
  final AuthRepository authRepository;

  //controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AuthLoginCubit(this.authRepository) : super(AuthLoginState());

  Future<UserModel?> login(String email, String password) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final user = await authRepository.login(email: email, password: password);
      emit(state.copyWith(status: Status.success));
      return user;
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
      return null;
    }
  }
}
