part of 'phone_verification_cubit.dart';

enum PhoneVerificationStatus {
  initial,
  sendingCode,
  codeSent,
  verifying,
  verified,
  error,
}

class PhoneVerificationState extends Equatable {
  final PhoneVerificationStatus status;
  final String? phoneNumber;
  final String countryCode;
  final bool canResendCode;
  final int resendTimer;
  final String? errorMessage;
  final String? expectedCode;
  final int fetchCodeTimer;

  const PhoneVerificationState({
    this.status = PhoneVerificationStatus.initial,
    this.phoneNumber,
    this.countryCode = '+52',
    this.canResendCode = false,
    this.resendTimer = 60,
    this.errorMessage,
    this.expectedCode,
    this.fetchCodeTimer = 0,
  });

  PhoneVerificationState copyWith({
    PhoneVerificationStatus? status,
    String? phoneNumber,
    String? countryCode,
    bool? canResendCode,
    int? resendTimer,
    String? errorMessage,
    String? expectedCode,
    int? fetchCodeTimer,
  }) {
    return PhoneVerificationState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      canResendCode: canResendCode ?? this.canResendCode,
      resendTimer: resendTimer ?? this.resendTimer,
      errorMessage: errorMessage ?? this.errorMessage,
      expectedCode: expectedCode ?? this.expectedCode,
      fetchCodeTimer: fetchCodeTimer ?? this.fetchCodeTimer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    phoneNumber,
    countryCode,
    canResendCode,
    resendTimer,
    errorMessage,
    expectedCode,
    fetchCodeTimer,
  ];
}
