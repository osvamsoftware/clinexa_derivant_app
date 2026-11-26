import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
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
            title: s.registerSuccessTitle,
            successMessage: s.register_successMessage,
            buttonLabel: s.login,
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
    final c = context.clx;
    final t = context.clxText;
    return Scaffold(
      appBar: const ClxAppBar(),
      body: Form(
        key: cubit.formStep3Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(ClxSpace.s6, ClxSpace.s4, ClxSpace.s6, ClxSpace.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClxStepper(current: 3, total: 3, label: s.registerStepTerms),
              const SizedBox(height: ClxSpace.s6),
              ClxPageHeader(title: s.termsTitle, subtitle: s.registerTermsSubtitle),
              const SizedBox(height: ClxSpace.s6),
              Container(
                height: MediaQuery.of(context).size.height * 0.42,
                decoration: BoxDecoration(
                  color: c.surfaceRaised,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(ClxRadius.lg),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(ClxSpace.s5),
                    child: Text(_termsText, style: t.bodySm.copyWith(color: c.ink, fontSize: 14, height: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: ClxSpace.s5),
              ClxChoiceTile(
                key: const Key('register_terms_checkbox'),
                multi: true,
                selected: _termsAccepted,
                title: s.termsAcceptLabel,
                onTap: () => setState(() => _termsAccepted = !_termsAccepted),
              ),
              const SizedBox(height: ClxSpace.s8),
              ClxButton(
                label: s.signup,
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

// Texto legal de los términos (contenido provisto por el equipo; se muestra
// tal cual).
const String _termsText = """Términos y Condiciones de Uso

Bienvenido a Clinexapp. Al crear una cuenta, usted acepta cumplir y estar sujeto a los siguientes términos y condiciones de uso, que junto con nuestra política de privacidad gobiernan la relación de Clinexapp con usted en relación con esta aplicación.

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
En ningún caso Clinexapp, ni sus directores, empleados, socios, agentes, proveedores o afiliados, serán responsables por daños indirectos, incidentales, especiales, consecuentes o punitivos.

8. Ley Aplicable
Estos Términos se regirán e interpretarán de acuerdo con las leyes vigentes, sin tener en cuenta sus disposiciones sobre conflictos de leyes.

Al marcar la casilla de verificación, usted confirma que ha leído, entendido y aceptado estos términos y condiciones y se compromete a cumplirlos al utilizar la aplicación.""";
