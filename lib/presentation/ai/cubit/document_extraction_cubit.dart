import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';

/// IA-04 · Lectura de estudios por foto o PDF. El archivo solo viaja para la
/// lectura: no se guarda en el teléfono ni en el servidor.
class DocumentExtractionCubit
    extends Cubit<AiRequestState<DocumentExtraction>> {
  DocumentExtractionCubit(this._repository) : super(const AiRequestState());

  final AiRepository _repository;

  /// Tope del contrato (8 MB).
  static const maxBytes = 8 * 1024 * 1024;

  /// Código local para "archivo demasiado grande" (la pantalla lo traduce).
  static const tooLargeCode = 413;

  /// Código local para "formato no admitido".
  static const unsupportedCode = 415;

  static String? mimeFor(String filename) {
    final n = filename.toLowerCase();
    if (n.endsWith('.pdf')) return 'application/pdf';
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }

  Future<void> extract({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (state.isLoading) return;
    final mime = mimeFor(filename);
    if (mime == null) {
      emit(state.failure(const AiException(unsupportedCode)));
      return;
    }
    if (bytes.lengthInBytes > maxBytes) {
      emit(state.failure(const AiException(tooLargeCode)));
      return;
    }
    emit(
      const AiRequestState<DocumentExtraction>(status: AiRequestStatus.loading),
    );
    try {
      final result = await _repository.extractDocument(
        bytes: bytes,
        filename: filename,
        mimeType: mime,
      );
      if (!isClosed) emit(state.success(result));
    } catch (e) {
      if (!isClosed) emit(state.failure(asAiException(e)));
    }
  }

  void reset() => emit(const AiRequestState());
}
