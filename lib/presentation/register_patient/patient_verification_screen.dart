import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/phone_verification/cubit/phone_verification_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/patients/patients_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PatientVerificationScreen extends StatelessWidget {
  static const path = "patient-verification";

  const PatientVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationCubit = context.read<PatientRegistrationCubit>();
    final repository = context.read<PatientRepository>();

    return BlocProvider(
      create: (_) => PhoneVerificationCubit(repository),
      child: PatientVerificationScreenView(
        registrationCubit: registrationCubit,
      ),
    );
  }
}

class PatientVerificationScreenView extends StatelessWidget {
  final PatientRegistrationCubit registrationCubit;

  const PatientVerificationScreenView({
    super.key,
    required this.registrationCubit,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Controllers para los campos de código
    final codeControllers = List.generate(6, (_) => TextEditingController());
    final codeFocusNodes = List.generate(6, (_) => FocusNode());

    return Scaffold(
      backgroundColor: AppColors.neutral99,
      appBar: AppBar(
        backgroundColor: AppColors.neutral99,
        title: const Text(
          'Verificación por WhatsApp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          // Listener para PhoneVerificationCubit
          BlocListener<PhoneVerificationCubit, PhoneVerificationState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == PhoneVerificationStatus.verified) {
                // Código verificado exitosamente, guardar paciente
                registrationCubit.savePatient(
                  createdBy: context.read<AuthCubit>().state.user?.id ?? '',
                );
              } else if (state.status == PhoneVerificationStatus.error) {
                // Mostrar error de verificación
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? 'Error al verificar código',
                );
              }
            },
          ),
          // Listener para PatientRegistrationCubit
          BlocListener<PatientRegistrationCubit, PatientRegistrationState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == PatientRegistrationStatus.loading) {
                CustomDialogs.loadingDialog(context);
              } else if (state.status == PatientRegistrationStatus.success) {
                context.pop(); // Close loading
                CustomDialogs.successDialog(
                  context: context,
                  successMessage: 'Paciente registrado exitosamente',
                  onPressed: () {
                    context.pop(); // Close success dialog
                    context.pop(); // Close verification screen
                    context.pop(); // Close signature screen
                    context.goNamed(PatientsScreen.path);
                  },
                );
                return;
              } else if (state.status == PatientRegistrationStatus.error) {
                if (Navigator.canPop(context)) {
                  context.pop(); // Close loading if it was opened
                }
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? 'Error al guardar paciente',
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Subtítulo
              Center(
                child: Text(
                  'Introduce tus datos para recibir el código de acceso médico.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral50,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Selector de país y número de WhatsApp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de país
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary95,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CountryCodePicker(
                      onChanged: (countryCode) {
                        final cubit = context.read<PhoneVerificationCubit>();
                        cubit.setPhoneNumber(
                          cubit.state.phoneNumber ?? '',
                          countryCode.dialCode ?? '+52',
                        );
                      },
                      initialSelection: 'MX',
                      favorite: const ['+52', 'MX'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Campo de número de WhatsApp
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary95,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          final cubit = context.read<PhoneVerificationCubit>();
                          cubit.setPhoneNumber(value, cubit.state.countryCode);
                        },
                        decoration: InputDecoration(
                          hintText: '55 1234 5678',
                          hintStyle: TextStyle(color: AppColors.neutral70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Aviso importante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary95,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: AppColors.primary40, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aviso importante',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary40,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.whatsappVerificationNoticeDetailed,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral40,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón Enviar Código (solo si NO se ha enviado)
              BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
                builder: (context, state) {
                  final isCodeSent =
                      state.status == PhoneVerificationStatus.codeSent ||
                      state.status == PhoneVerificationStatus.verifying;

                  if (isCodeSent) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      CustomButton(
                        text: 'Enviar Código',
                        isLoading:
                            state.status == PhoneVerificationStatus.sendingCode,
                        onPressed: () {
                          context
                              .read<PhoneVerificationCubit>()
                              .sendVerificationCode();
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),

              // Campos de código (SOLO SI SE ENVIÓ EL CÓDIGO)
              BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
                builder: (context, state) {
                  final isCodeSent =
                      state.status == PhoneVerificationStatus.codeSent ||
                      state.status == PhoneVerificationStatus.verifying;

                  if (!isCodeSent) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      // Label del código
                      Center(
                        child: Text(
                          'Ingrese el número de validación recibido por el paciente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral50,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (state.fetchCodeTimer > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: Text(
                              'Por favor espere ${state.fetchCodeTimer} segundo${state.fetchCodeTimer == 1 ? '' : 's'} para obtener el código de prueba...',
                              style: TextStyle(
                                color: AppColors.primary40,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else if (state.expectedCode != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: Text(
                              'Código esperado para pruebas: ${state.expectedCode}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                      // Campos de código (6 dígitos)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            height: 60,
                            child: TextField(
                              controller: codeControllers[index],
                              focusNode: codeFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary40,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.neutral80,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary40,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Moverse al siguiente campo
                                  if (index < 5) {
                                    codeFocusNodes[index + 1].requestFocus();
                                  } else {
                                    // Último campo, verificar código completo
                                    final code = codeControllers
                                        .map((c) => c.text)
                                        .join();
                                    if (code.length == 6) {
                                      context
                                          .read<PhoneVerificationCubit>()
                                          .verifyCode(code);
                                    }
                                  }
                                } else {
                                  // Campo borrado, regresar al anterior
                                  if (index > 0) {
                                    codeFocusNodes[index - 1].requestFocus();
                                  }
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Reintentar
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: '¿No recibiste el código? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral60,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: state.canResendCode
                                      ? () {
                                          context
                                              .read<PhoneVerificationCubit>()
                                              .sendVerificationCode();
                                        }
                                      : null,
                                  child: Text(
                                    state.canResendCode
                                        ? 'Reintentar ahora'
                                        : 'Reintentar en ${(state.resendTimer ~/ 60).toString().padLeft(2, '0')}:${(state.resendTimer % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: state.canResendCode
                                          ? AppColors.primary40
                                          : AppColors.neutral60,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Botón "Verificar y Continuar"
                      CustomButton(
                        text: 'Verificar y Continuar',
                        isLoading:
                            state.status == PhoneVerificationStatus.verifying,
                        onPressed: () {
                          final code = codeControllers
                              .map((c) => c.text)
                              .join();
                          if (code.length == 6) {
                            context.read<PhoneVerificationCubit>().verifyCode(
                              code,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
