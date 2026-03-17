import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactProtocolScreen extends StatelessWidget {
  static const path = '/contact-protocol';

  const ContactProtocolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // Placeholder number - User to provide actual number
    const contactNumber = "5491112345678";

    return Scaffold(
      appBar: AppBar(
        title: Text(s.contactInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary90, // Light purple background
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative dots
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary60, // Darker purple dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 30,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary60.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Main Icon
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary40, // Deep purple
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              s.contactTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Or neutral10
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              s.contactDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral40),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Schedule Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary95,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    size: 16,
                    color: AppColors.primary40,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.contactSchedule,
                    style: const TextStyle(
                      color: AppColors.primary40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary40,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
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
                      await launchUrl(
                        webUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              // Using a generic error message or you could add to l10n
                              'No se pudo abrir WhatsApp',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint("Error launching WhatsApp: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al abrir WhatsApp: $e')),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.contactButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.send_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
