import 'package:clinexa_derivant_app/core/legal/legal_catalog.dart';
import 'package:clinexa_derivant_app/core/legal/legal_document.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/legal/legal_document_screen.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

class RegisterProfileScreen extends StatelessWidget {
  static const path = "/register-profile";

  const RegisterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        final s = S.of(context);

        // =====================================================
        // 🔄 LOADING
        // =====================================================
        if (state.status == RegisterStatus.loading) {
          CustomDialogs.loadingDialog(context);
        }

        // =====================================================
        // ❌ ERROR
        // =====================================================
        if (state.status == RegisterStatus.error) {
          // cerrar loading
          context.pop(context);

          CustomDialogs.errorDialog(
            context,
            state.errorMessage ?? s.errorOccurred,
          );
        }

        // =====================================================
        // ✅ SUCCESS
        // =====================================================
        if (state.status == RegisterStatus.success) {
          CustomDialogs.successDialog(
            context: context,
            successMessage: s.register_successMessage,
            onPressed: () {
              // enviar al login
              context.pushReplacement(LoginScreen.path);
            },
          );
        }
      },
      child: const RegisterProfileView(),
    );
  }
}

class RegisterProfileView extends StatefulWidget {
  const RegisterProfileView({super.key});

  @override
  State<RegisterProfileView> createState() => _RegisterProfileViewState();
}

class _RegisterProfileViewState extends State<RegisterProfileView> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.createAccount)),
      body: Form(
        key: cubit.formStep3Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Por favor acepta los términos y condiciones para continuar",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Aquí había un texto genérico embebido que no era el documento
              // legal que rige la relación. Ahora se abre el documento
              // vigente: el mismo que está publicado y declarado ante Apple,
              // empaquetado como asset para poder leerse sin conexión.
              const _LegalDocumentButton(
                document: LegalCatalog.referentTerms,
                label:
                    'Al registrarme acepto los Términos y Condiciones del '
                    'Médico Referente',
              ),
              const SizedBox(height: 12),
              const _LegalDocumentButton(
                document: LegalCatalog.privacyPolicy,
                label: 'Leer la Política de Privacidad',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (val) {
                  setState(() {
                    _termsAccepted = val ?? false;
                  });
                },
                title: const Text(
                  "He leído y estoy de acuerdo con los términos y condiciones de la app y mi compromiso al crear la cuenta.",
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: s.createAccount,
                onPressed: _termsAccepted
                    ? () {
                        if (cubit.formStep3Key.currentState!.validate()) {
                          cubit.submit();
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón que abre un documento legal empaquetado en la app.
///
/// El texto del botón dice explícitamente qué se acepta y a qué documento
/// lleva: al registrarse, el médico queda obligado por ese documento, y tiene
/// que poder leerlo antes de marcar la casilla.
class _LegalDocumentButton extends StatelessWidget {
  final LegalDocument document;
  final String label;

  const _LegalDocumentButton({required this.document, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () =>
            context.push('${LegalDocumentScreen.path}/${document.slug}'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
