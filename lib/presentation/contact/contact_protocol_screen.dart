import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactProtocolScreen extends StatelessWidget {
  static const path = '/contact-protocol';

  const ContactProtocolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // Placeholder number - User to provide actual number
    const contactNumber = "5491112345678";

    final c = context.clx;
    final t = context.clxText;

    return Scaffold(
      appBar: ClxAppBar(title: s.contactSubtitle),
      bottomNavigationBar: ClxBottomBar(
        child: ClxButton(
          label: s.contactButton,
          icon: LucideIcons.messageCircle,
          onPressed: () async {
            final user = context.read<AuthCubit>().state.user;
            if (user == null) return;

            final message = s.contactMessage(
              user.firstName ?? "",
              user.medicalLicense ?? "",
              user.id ?? "",
            );

            final whatsappUrl = Uri.parse(
              "whatsapp://send?phone=$contactNumber&text=${Uri.encodeComponent(message)}",
            );
            final webUrl = Uri.parse(
              "https://wa.me/$contactNumber?text=${Uri.encodeComponent(message)}",
            );

            try {
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(
                  whatsappUrl,
                  mode: LaunchMode.externalApplication,
                );
              } else if (await canLaunchUrl(webUrl)) {
                await launchUrl(webUrl, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ClxToast.error(context, s.whatsappOpenError);
                }
              }
            } catch (e) {
              debugPrint("Error launching WhatsApp: $e");
              if (context.mounted) {
                ClxToast.error(context, s.whatsappOpenError);
              }
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ClxSpace.s6,
          ClxSpace.s8,
          ClxSpace.s6,
          ClxSpace.s8,
        ),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.brandBlueSoft,
                borderRadius: BorderRadius.circular(ClxRadius.xl),
              ),
              child: Icon(
                LucideIcons.clipboardPlus,
                size: 32,
                color: c.onBrandBlueSoft,
              ),
            ),
          ),
          const SizedBox(height: ClxSpace.s6),
          Text(s.contactTitle, style: t.h1, textAlign: TextAlign.center),
          const SizedBox(height: ClxSpace.s3),
          Text(
            s.contactDescription,
            style: t.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ClxSpace.s6),
          Center(
            child: ClxBadge(
              label: s.contactSchedule,
              tone: ClxTone.info,
              icon: LucideIcons.clock,
            ),
          ),
          const SizedBox(height: ClxSpace.s8),
          ClxCard(
            padding: const EdgeInsets.all(ClxSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.contactChecklistTitle.toUpperCase(), style: t.label),
                const SizedBox(height: ClxSpace.s3),
                for (final item in [
                  s.contactChecklist1,
                  s.contactChecklist2,
                  s.contactChecklist3,
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: ClxSpace.s2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            LucideIcons.check,
                            size: 16,
                            color: c.success,
                          ),
                        ),
                        const SizedBox(width: ClxSpace.s2),
                        Expanded(child: Text(item, style: t.body)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
