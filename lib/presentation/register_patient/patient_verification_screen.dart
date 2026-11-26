import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/phone_verification/cubit/phone_verification_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
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

class PatientVerificationScreenView extends StatefulWidget {
  final PatientRegistrationCubit registrationCubit;

  const PatientVerificationScreenView({
    super.key,
    required this.registrationCubit,
  });

  @override
  State<PatientVerificationScreenView> createState() =>
      _PatientVerificationScreenViewState();
}

class _PatientVerificationScreenViewState
    extends State<PatientVerificationScreenView> {
  // Controllers para los campos de código
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());

  PatientRegistrationCubit get registrationCubit => widget.registrationCubit;

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  bool _isCodeSent(PhoneVerificationState state) =>
      state.status == PhoneVerificationStatus.codeSent ||
      state.status == PhoneVerificationStatus.verifying;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;

    return Scaffold(
      appBar: ClxAppBar(title: s.whatsappVerificationTitle),
      bottomNavigationBar: ClxBottomBar(
        child: BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
          builder: (context, state) {
            if (!_isCodeSent(state)) {
              return ClxButton(
                key: const Key('verification_send_code'),
                label: s.sendCode,
                icon: LucideIcons.messageCircle,
                loading: state.status == PhoneVerificationStatus.sendingCode,
                onPressed: () {
                  context.read<PhoneVerificationCubit>().sendVerificationCode();
                },
              );
            }
            return ClxButton(
              key: const Key('verification_verify_code'),
              label: s.verifyAndRegister,
              loading: state.status == PhoneVerificationStatus.verifying,
              onPressed: () {
                final code = _code;
                if (code.length == 6) {
                  context.read<PhoneVerificationCubit>().verifyCode(code);
                }
              },
            );
          },
        ),
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
                  state.errorMessage ?? s.errorVerifyingCode,
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
                  title: s.patientReferredTitle,
                  successMessage: s.patientReferredMessage,
                  buttonLabel: s.seeMyPatients,
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
                  state.errorMessage ?? s.errorSavingPatient,
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ClxSpace.s4,
            ClxSpace.s5,
            ClxSpace.s4,
            ClxSpace.s8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClxStepper(
                current: 3,
                total: 3,
                label: s.referralStepVerification,
              ),
              const SizedBox(height: ClxSpace.s5),
              Text(s.whatsappVerificationSubtitle, style: t.bodyMuted),
              const SizedBox(height: ClxSpace.s6),

              // Selector de país y número de WhatsApp
              ClxFieldLabel(s.patientWhatsapp),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      border: Border.all(color: c.borderStrong),
                      borderRadius: BorderRadius.circular(ClxRadius.md),
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
                      flagWidth: 24,
                      textStyle: t.data.copyWith(fontSize: 15),
                      dialogTextStyle: t.body,
                      searchStyle: t.body,
                      dialogBackgroundColor: c.surfaceRaised,
                      barrierColor: c.ink.withValues(alpha: 0.4),
                      searchDecoration: clxInputDecoration(
                        context,
                        hint: s.search,
                        icon: LucideIcons.search,
                      ),
                      closeIcon: Icon(LucideIcons.x, color: c.ink, size: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ClxSpace.s2,
                      ),
                    ),
                  ),
                  const SizedBox(width: ClxSpace.s3),

                  // Campo de número de WhatsApp
                  Expanded(
                    child: ClxTextField(
                      key: const Key('verification_phone_field'),
                      hint: '55 1234 5678',
                      mono: true,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        final cubit = context.read<PhoneVerificationCubit>();
                        cubit.setPhoneNumber(value, cubit.state.countryCode);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ClxSpace.s5),

              // Aviso importante
              ClxNotice(
                tone: ClxTone.warning,
                title: s.importantNotice,
                message: s.whatsappVerificationNoticeDetailed,
              ),

              // Campos de código (solo si se envió el código)
              BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
                builder: (context, state) {
                  if (!_isCodeSent(state)) return const SizedBox.shrink();

                  final timer =
                      '${(state.resendTimer ~/ 60).toString().padLeft(2, '0')}:${(state.resendTimer % 60).toString().padLeft(2, '0')}';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: ClxSpace.s8),
                      Text(s.verificationCodeTitle, style: t.h2),
                      const SizedBox(height: ClxSpace.s1),
                      Text(s.verificationCodeSubtitle, style: t.bodySm),
                      const SizedBox(height: ClxSpace.s4),

                      // El código de verificación ya no se muestra en
                      // pantalla ni se consulta al servidor: solo llega por
                      // WhatsApp.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 46,
                            child: TextField(
                              controller: _codeControllers[index],
                              focusNode: _codeFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: t.dataLg.copyWith(fontSize: 22),
                              cursorColor: c.brandBlue,
                              decoration:
                                  clxInputDecoration(
                                    context,
                                    counterText: '',
                                  ).copyWith(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Moverse al siguiente campo
                                  if (index < 5) {
                                    _codeFocusNodes[index + 1].requestFocus();
                                  } else {
                                    // Último campo, verificar código completo
                                    final code = _code;
                                    if (code.length == 6) {
                                      context
                                          .read<PhoneVerificationCubit>()
                                          .verifyCode(code);
                                    }
                                  }
                                } else {
                                  // Campo borrado, regresar al anterior
                                  if (index > 0) {
                                    _codeFocusNodes[index - 1].requestFocus();
                                  }
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: ClxSpace.s4),

                      // Reenviar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.codeNotReceived, style: t.bodySm),
                          ClxButton.ghost(
                            label: state.canResendCode
                                ? s.resendCode
                                : s.resendCodeIn(timer),
                            size: ClxButtonSize.sm,
                            onPressed: state.canResendCode
                                ? () {
                                    context
                                        .read<PhoneVerificationCubit>()
                                        .sendVerificationCode();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
