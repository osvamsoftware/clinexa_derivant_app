import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/signature/cubit/signature_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/signature/cubit/signature_state.dart'
    as signature_state;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';

class PatientSignatureScreen extends StatelessWidget {
  static const path = "patient-signature";

  const PatientSignatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignatureCubit(context.read<PatientRepository>()),
      child: const PatientSignatureScreenView(),
    );
  }
}

class PatientSignatureScreenView extends StatefulWidget {
  const PatientSignatureScreenView({super.key});

  @override
  State<PatientSignatureScreenView> createState() => _PatientSignatureScreenViewState();
}

class _PatientSignatureScreenViewState extends State<PatientSignatureScreenView> {
  // La firma se exporta como imagen sobre fondo blanco (papel), en los dos
  // temas: el trazo va en tinta oscura para que se lea en el PDF/imagen.
  late final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: ClxColors.ink,
    exportBackgroundColor: ClxColors.surfaceRaised,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientCubit = context.read<PatientRegistrationCubit>();
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;

    return BlocConsumer<SignatureCubit, signature_state.SignatureState>(
      listener: (context, state) {
        if (state is signature_state.SignatureSuccess) {
          patientCubit.setSignatureUrl(state.url, state.bytes);
          context.push('/patient-verification', extra: patientCubit);
        } else if (state is signature_state.SignatureError) {
          ClxToast.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: ClxAppBar(title: s.signature),
          bottomNavigationBar: ClxBottomBar(
            child: ClxButton(
              key: const Key('signature_next_button'),
              label: s.continueToVerification,
              trailingIcon: LucideIcons.arrowRight,
              loading: state is signature_state.SignatureLoading,
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  final signature = await _signatureController.toPngBytes();
                  if (signature != null && context.mounted) {
                    context.read<SignatureCubit>().uploadSignature(signature);
                  }
                } else {
                  ClxToast.error(context, s.signatureRequired);
                }
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s5, ClxSpace.s4, ClxSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClxStepper(current: 2, total: 3, label: s.referralStepSignature),
                const SizedBox(height: ClxSpace.s5),
                ClxNotice(
                  icon: LucideIcons.handHeart,
                  title: s.signatureHandOverTitle,
                  message: s.signatureInstructions,
                ),
                const SizedBox(height: ClxSpace.s6),
                Row(
                  children: [
                    Expanded(child: Text(s.signatureAreaLabel.toUpperCase(), style: t.label)),
                    ClxButton.ghost(
                      label: s.clearSignature,
                      icon: LucideIcons.eraser,
                      size: ClxButtonSize.sm,
                      onPressed: () {
                        _signatureController.clear();
                        patientCubit.clearSignature();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: ClxSpace.s2),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ClxColors.surfaceRaised,
                      border: Border.all(color: c.borderStrong, width: 1.5),
                      borderRadius: BorderRadius.circular(ClxRadius.lg),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ClxRadius.lg - 1),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Signature(
                              controller: _signatureController,
                              backgroundColor: ClxColors.surfaceRaised,
                            ),
                          ),
                          // Línea de firma
                          Positioned(
                            left: ClxSpace.s6,
                            right: ClxSpace.s6,
                            bottom: ClxSpace.s12,
                            child: IgnorePointer(
                              child: Container(height: 1, color: ClxColors.border),
                            ),
                          ),
                          // Indicación mientras no hay firma
                          ValueListenableBuilder(
                            valueListenable: _signatureController,
                            builder: (context, _, __) {
                              if (_signatureController.isNotEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Center(
                                child: IgnorePointer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(ClxSpace.s6),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(LucideIcons.signature, size: 32, color: ClxColors.inkSubtle),
                                        const SizedBox(height: ClxSpace.s3),
                                        Text(
                                          s.signaturePlaceholder,
                                          style: t.bodySm.copyWith(color: ClxColors.inkSubtle),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
