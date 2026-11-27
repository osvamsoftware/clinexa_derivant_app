import 'dart:typed_data';

import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/document_extraction_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// IA-04 · Lectura de un estudio por foto, imagen o PDF. Devuelve el bloque
/// `notes_text` para agregar a las notas clínicas, o null si se canceló.
Future<String?> showDocumentReaderSheet(BuildContext context) {
  final s = S.of(context);
  return ClxSheet.show<String>(
    context,
    title: s.aiReadStudyTitle,
    child: BlocProvider(
      create: (_) => DocumentExtractionCubit(context.read<AiRepository>()),
      child: const DocumentReaderBody(),
    ),
  );
}

class DocumentReaderBody extends StatelessWidget {
  const DocumentReaderBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      DocumentExtractionCubit,
      AiRequestState<DocumentExtraction>
    >(
      builder: (context, state) {
        final s = S.of(context);
        final Widget child = switch (state.status) {
          AiRequestStatus.idle => const _SourcePicker(key: ValueKey('pick')),
          AiRequestStatus.loading => ClxAiThinking(
            key: const ValueKey('thinking'),
            title: s.aiThinkingTitle,
            messages: [
              s.aiReadStudyThinking1,
              s.aiReadStudyThinking2,
              s.aiReadStudyThinking3,
            ],
          ),
          AiRequestStatus.success => _Findings(
            key: const ValueKey('result'),
            result: state.data!,
          ),
          AiRequestStatus.failure => Column(
            key: const ValueKey('error'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AiErrorNotice(error: state.error),
              const SizedBox(height: ClxSpace.s5),
              const _SourcePicker(),
            ],
          ),
        };
        return SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: child,
          ),
        );
      },
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final cubit = context.read<DocumentExtractionCubit>();
    final s = S.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      // Con compresión, la cámara y la galería entregan JPEG.
      var name = file.name;
      if (DocumentExtractionCubit.mimeFor(name) == null) name = 'estudio.jpg';
      await cubit.extract(bytes: bytes, filename: name);
    } catch (_) {
      if (context.mounted) ClxToast.error(context, s.aiPickError);
    }
  }

  Future<void> _pickPdf(BuildContext context) async {
    final cubit = context.read<DocumentExtractionCubit>();
    final s = S.of(context);
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      final file = res?.files.single;
      final Uint8List? bytes = file?.bytes;
      if (file == null || bytes == null) return;
      await cubit.extract(bytes: bytes, filename: file.name);
    } catch (_) {
      if (context.mounted) ClxToast.error(context, s.aiPickError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.aiReadStudySubtitle, style: context.clxText.bodySm),
        const SizedBox(height: ClxSpace.s4),
        ClxAiButton(
          key: const Key('ai_study_camera'),
          label: s.aiReadStudyCamera,
          icon: LucideIcons.camera,
          onPressed: () => _pickImage(context, ImageSource.camera),
        ),
        const SizedBox(height: ClxSpace.s3),
        Row(
          children: [
            Expanded(
              child: ClxButton.secondary(
                key: const Key('ai_study_gallery'),
                label: s.aiReadStudyGallery,
                icon: LucideIcons.image,
                size: ClxButtonSize.md,
                onPressed: () => _pickImage(context, ImageSource.gallery),
              ),
            ),
            const SizedBox(width: ClxSpace.s3),
            Expanded(
              child: ClxButton.secondary(
                key: const Key('ai_study_pdf'),
                label: s.aiReadStudyPdf,
                icon: LucideIcons.fileText,
                size: ClxButtonSize.md,
                onPressed: () => _pickPdf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: ClxSpace.s4),
        ClxNotice(
          tone: ClxTone.info,
          icon: LucideIcons.shieldCheck,
          message: s.aiReadStudyPrivacy,
        ),
      ],
    );
  }
}

class _Findings extends StatelessWidget {
  const _Findings({super.key, required this.result});

  final DocumentExtraction result;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final hasNotes = result.notesText.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClxAiReveal(
          child: ClxAiSurface(
            padding: const EdgeInsets.all(ClxSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardHeader(
                  title: s.aiReadStudyFindings,
                  trailing: ClxAiTag(label: s.aiSuggestedTag),
                ),
                const SizedBox(height: ClxSpace.s3),
                if (result.findings.isEmpty)
                  Text(s.aiReadStudyNoFindings, style: t.bodyMuted)
                else
                  for (var i = 0; i < result.findings.length; i++)
                    ClxAiReveal(
                      index: i + 1,
                      child: _FindingRow(
                        finding: result.findings[i],
                        last: i == result.findings.length - 1,
                      ),
                    ),
              ],
            ),
          ),
        ),
        for (final w in result.warnings) ...[
          const SizedBox(height: ClxSpace.s3),
          ClxNotice(tone: ClxTone.warning, message: w),
        ],
        if (hasNotes) ...[
          const SizedBox(height: ClxSpace.s4),
          Text(s.aiReadStudyNotesPreview.toUpperCase(), style: t.label),
          const SizedBox(height: ClxSpace.s2),
          Container(
            key: const Key('ai_study_notes_text'),
            padding: const EdgeInsets.all(ClxSpace.s3),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(ClxRadius.md),
            ),
            child: Text(
              result.notesText.trim(),
              style: t.bodySm.copyWith(color: c.ink),
            ),
          ),
        ],
        const SizedBox(height: ClxSpace.s3),
        ClxAiDisclaimer(text: s.aiDisclaimer),
        const SizedBox(height: ClxSpace.s4),
        ClxAiButton(
          key: const Key('ai_study_add_notes'),
          label: s.aiReadStudyAdd,
          icon: LucideIcons.textCursorInput,
          onPressed: hasNotes
              ? () => Navigator.of(context).pop(result.notesText.trim())
              : null,
        ),
        const SizedBox(height: ClxSpace.s2),
        Center(
          child: ClxButton.ghost(
            label: s.aiReadStudyAnother,
            icon: LucideIcons.rotateCw,
            onPressed: context.read<DocumentExtractionCubit>().reset,
          ),
        ),
      ],
    );
  }
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({required this.finding, required this.last});

  final DocumentFinding finding;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ClxSpace.s2),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(finding.label, style: t.bodyStrong),
                if (finding.date.isNotEmpty)
                  Text(
                    aiDate(finding.date),
                    style: t.bodySm.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(width: ClxSpace.s3),
          Text(
            [finding.value, finding.unit].where((e) => e.isNotEmpty).join(' '),
            style: t.data,
          ),
        ],
      ),
    );
  }
}
