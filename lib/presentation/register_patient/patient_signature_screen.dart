import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/signature/cubit/signature_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/signature/cubit/signature_state.dart'
    as signature_state;
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
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

class PatientSignatureScreenView extends StatelessWidget {
  const PatientSignatureScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final patientCubit = context.read<PatientRegistrationCubit>();

    // Crear SignatureController
    final signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primary40,
      exportBackgroundColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: AppColors.neutral99,
      appBar: AppBar(
        backgroundColor: AppColors.neutral99,
        title: const Text(
          'Firma del Paciente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<SignatureCubit, signature_state.SignatureState>(
        listener: (context, state) {
          if (state is signature_state.SignatureSuccess) {
            patientCubit.setSignatureUrl(state.url, state.bytes);
            context.push('/patient-verification', extra: patientCubit);
          } else if (state is signature_state.SignatureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger40,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucciones
                Text(
                  'Por favor, entregue el dispositivo al paciente para capturar su firma.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral40,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Label "ESPACIO DE FIRMA"
                Text(
                  'ESPACIO DE FIRMA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral50,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Área de firma con borde punteado
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.neutral80,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // Signature canvas
                          Signature(
                            controller: signatureController,
                            backgroundColor: Colors.white,
                          ),

                          // Placeholder cuando no hay firma
                          Center(
                            child: IgnorePointer(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 48,
                                    color: AppColors.neutral80,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Use su dedo o un lápiz óptico para firmar aquí',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.neutral60,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón "Limpiar firma"
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      signatureController.clear();
                      patientCubit.clearSignature();
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.primary40,
                    ),
                    label: Text(
                      'Limpiar firma',
                      style: TextStyle(
                        color: AppColors.primary40,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón "Siguiente"
                CustomButton(
                  text: 'Siguiente',
                  isLoading: state is signature_state.SignatureLoading,
                  onPressed: () async {
                    if (signatureController.isNotEmpty) {
                      final signature = await signatureController.toPngBytes();
                      if (signature != null) {
                        // ignore: use_build_context_synchronously
                        context.read<SignatureCubit>().uploadSignature(
                          signature,
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Por favor, firme para continuar',
                          ),
                          backgroundColor: AppColors.danger40,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
