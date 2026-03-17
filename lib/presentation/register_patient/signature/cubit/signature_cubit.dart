import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'signature_state.dart';

class SignatureCubit extends Cubit<SignatureState> {
  final PatientRepository _repository;

  SignatureCubit(this._repository) : super(SignatureInitial());

  Future<void> uploadSignature(Uint8List signatureData) async {
    try {
      emit(SignatureLoading());
      final url = await _repository.uploadSignature(signatureData);
      emit(SignatureSuccess(url, signatureData));
    } catch (e) {
      emit(SignatureError(e.toString()));
    }
  }
}
