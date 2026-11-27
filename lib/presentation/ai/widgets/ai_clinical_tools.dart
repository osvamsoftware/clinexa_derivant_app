import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/eligibility_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/dictation_sheet.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/document_reader_sheet.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones de IA junto a las notas clínicas: dictar (IA-05) y leer un
/// estudio por foto o PDF (IA-04).
class AiClinicalTools extends StatelessWidget {
  const AiClinicalTools({super.key});

  /// Aplica lo que el médico confirmó del dictado. Nunca toca nombre,
  /// documento ni contacto.
  static void applyDictation(BuildContext context, DictationFields f) {
    final reg = context.read<PatientRegistrationCubit>();
    final elig = context.read<EligibilityCubit>();
    final gender = switch (f.sex) {
      'male' => 'Male',
      'female' => 'Female',
      'other' => 'Other',
      _ => null,
    };
    if (gender != null) reg.setGender(gender);
    elig.setDictatedAge(f.age);
    elig.addPathologies(f.pathologies);
    reg.appendNotes(f.notes);
  }

  Future<void> _dictate(BuildContext context) async {
    final s = S.of(context);
    final fields = await showDictationSheet(context);
    if (fields == null || !context.mounted) return;
    applyDictation(context, fields);
    ClxToast.show(context, s.aiDictationApplied, tone: ClxTone.ai);
  }

  Future<void> _readStudy(BuildContext context) async {
    final s = S.of(context);
    final text = await showDocumentReaderSheet(context);
    if (text == null || !context.mounted) return;
    context.read<PatientRegistrationCubit>().appendNotes(text);
    ClxToast.show(context, s.aiReadStudyAdded, tone: ClxTone.ai);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: ClxSpace.s4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: ClxAiButton(
              key: const Key('ai_dictate_button'),
              label: s.aiDictate,
              icon: LucideIcons.mic,
              compact: true,
              onPressed: () => _dictate(context),
            ),
          ),
          const SizedBox(width: ClxSpace.s3),
          Expanded(
            flex: 6,
            child: ClxAiButton(
              key: const Key('ai_read_study_button'),
              label: s.aiReadStudy,
              icon: LucideIcons.scanText,
              compact: true,
              onPressed: () => _readStudy(context),
            ),
          ),
        ],
      ),
    );
  }
}
