import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class SignatureState extends Equatable {
  const SignatureState();

  @override
  List<Object?> get props => [];
}

class SignatureInitial extends SignatureState {}

class SignatureLoading extends SignatureState {}

class SignatureSuccess extends SignatureState {
  final String url;
  final Uint8List bytes;
  const SignatureSuccess(this.url, this.bytes);

  @override
  List<Object?> get props => [url, bytes];
}

class SignatureError extends SignatureState {
  final String message;
  const SignatureError(this.message);

  @override
  List<Object?> get props => [message];
}
