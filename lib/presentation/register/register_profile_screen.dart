import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
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
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    """Términos y Condiciones de Uso

Bienvenido a Clinexa. Al crear una cuenta, usted acepta cumplir y estar sujeto a los siguientes términos y condiciones de uso, que junto con nuestra política de privacidad gobiernan la relación de Clinexa con usted en relación con esta aplicación.

1. Aceptación de los Términos
Al acceder y utilizar esta aplicación, usted acepta estar sujeto a estos términos y condiciones y a nuestra Política de Privacidad. Si no está de acuerdo con alguna parte de estos términos, no podrá utilizar nuestros servicios.

2. Uso de la Aplicación
Usted se compromete a utilizar la aplicación solo para fines legales y de una manera que no infrinja los derechos de, restrinja o inhiba el uso y disfrute de la aplicación por parte de cualquier tercero.

3. Cuenta de Usuario
Para acceder a ciertas funciones de la aplicación, debe crear una cuenta. Usted es responsable de mantener la confidencialidad de su cuenta y contraseña y de restringir el acceso a su dispositivo.

4. Privacidad
Su uso de la aplicación también está regido por nuestra Política de Privacidad. Por favor revise nuestra Política de Privacidad para entender nuestras prácticas.

5. Modificaciones
Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor inmediatamente después de su publicación en la aplicación.

6. Terminación
Podemos terminar o suspender su cuenta inmediatamente, sin previo aviso o responsabilidad, por cualquier motivo, incluyendo, sin limitación, si usted incumple los Términos.

7. Limitación de Responsabilidad
En ningún caso Clinexa, ni sus directores, empleados, socios, agentes, proveedores o afiliados, serán responsables por daños indirectos, incidentales, especiales, consecuentes o punitivos.

8. Ley Aplicable
Estos Términos se regirán e interpretarán de acuerdo con las leyes vigentes, sin tener en cuenta sus disposiciones sobre conflictos de leyes.

Al marcar la casilla de verificación, usted confirma que ha leído, entendido y aceptado estos términos y condiciones y se compromete a cumplirlos al utilizar la aplicación.""",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
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
