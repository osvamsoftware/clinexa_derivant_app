import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Error de una ruta de IA.
///
/// [detail] es el mensaje del backend (`{"detail": "…"}`), ya en español y
/// listo para mostrar tal cual. Es null cuando no hubo respuesta (sin red) o
/// el backend no mandó detalle: la pantalla muestra su propio texto.
class AiException implements Exception {
  const AiException(this.statusCode, [this.detail]);

  /// 0 = sin conexión.
  final int statusCode;
  final String? detail;

  @override
  String toString() => 'AiException($statusCode): ${detail ?? ''}';
}

/// Funciones de IA de la app Derivante (rutas `/ai/app/*`).
abstract class AiRepository {
  /// Estado de la IA. Se cachea en memoria; si la ruta no existe (404) la IA
  /// queda desactivada y la app funciona igual que sin ella.
  Future<AiStatus> status({bool refresh = false});

  /// IA-02: evalúa el caso contra los criterios de un protocolo.
  Future<EligibilityResult> evaluateEligibility({
    required String protocolId,
    required AiCase aiCase,
  });

  /// IA-02: vincula la evaluación al paciente ya registrado, con las
  /// correcciones del médico.
  Future<void> attachEligibility({
    required String eligibilityId,
    required String patientId,
    required Map<int, EligibilityStatus> reviewed,
  });

  /// IA-03.
  Future<ProtocolSuggestions> suggestProtocols(String description);

  /// IA-04: la imagen o el PDF no se guardan en el servidor.
  Future<DocumentExtraction> extractDocument({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });

  /// IA-05.
  Future<DictationFields> parseDictation(String transcript);

  /// IA-07.
  Future<RejectionFeedback> myRejections();

  /// IA-09. [history] ya viene recortada (máx. 6 mensajes).
  Future<AssistantAnswer> askAssistant({
    required String question,
    List<AssistantTurn> history = const [],
    String? protocolId,
  });
}

typedef TokenProvider = Future<String?> Function();
typedef SessionRefresher = Future<bool> Function();

/// Implementación HTTP. Usa la misma sesión que el resto de la app
/// ([ApiService]) pero su propio cliente, para poder enviar archivos y leer
/// el `detail` de cualquier error (el cliente general lo reemplaza en 404,
/// 429 y 5xx).
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    required String baseUrl,
    http.Client? client,
    TokenProvider? tokenProvider,
    SessionRefresher? refreshSession,
    this.timeout = const Duration(seconds: 60),
  }) : _base = baseUrl,
       _client = client ?? http.Client(),
       _token = tokenProvider ?? (() => ApiService().currentAccessToken()),
       _refresh = refreshSession ?? (() => ApiService().refreshSession());

  /// Base de las rutas de IA (por ejemplo `https://…/api/ai/app`).
  final String _base;
  final http.Client _client;
  final TokenProvider _token;
  final SessionRefresher _refresh;
  final Duration timeout;

  AiStatus? _status;
  Future<AiStatus>? _statusInFlight;

  @override
  Future<AiStatus> status({bool refresh = false}) {
    if (!refresh && _status != null) return Future.value(_status);
    return _statusInFlight ??= _loadStatus().whenComplete(
      () => _statusInFlight = null,
    );
  }

  Future<AiStatus> _loadStatus() async {
    try {
      final json = await _send(
        () => http.Request('GET', Uri.parse('$_base/status')),
      );
      return _status = AiStatus.fromMap(json);
    } on AiException catch (e) {
      // Backend sin estas rutas: se recuerda y se ocultan las funciones.
      if (e.statusCode == 404 || e.statusCode == 503) {
        return _status = const AiStatus.disabled();
      }
      // Sin red o sin sesión: se oculta por ahora y se reintenta luego.
      return const AiStatus.disabled();
    }
  }

  @override
  Future<EligibilityResult> evaluateEligibility({
    required String protocolId,
    required AiCase aiCase,
  }) async {
    final json = await _post('/eligibility', {
      'protocol_id': protocolId,
      'case': aiCase.toMap(),
    });
    return EligibilityResult.fromMap(json);
  }

  @override
  Future<void> attachEligibility({
    required String eligibilityId,
    required String patientId,
    required Map<int, EligibilityStatus> reviewed,
  }) async {
    await _post('/eligibility/${Uri.encodeComponent(eligibilityId)}/attach', {
      'patient_id': patientId,
      'reviewed_items': [
        for (final e in reviewed.entries)
          {'order': e.key, 'status': e.value.apiValue},
      ],
    });
  }

  @override
  Future<ProtocolSuggestions> suggestProtocols(String description) async =>
      ProtocolSuggestions.fromMap(
        await _post('/suggest-protocols', {'description': description}),
      );

  @override
  Future<DocumentExtraction> extractDocument({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final json = await _send(() {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/extract-document'),
      );
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );
      return req;
    });
    return DocumentExtraction.fromMap(json);
  }

  @override
  Future<DictationFields> parseDictation(String transcript) async =>
      DictationFields.fromMap(
        await _post('/parse-dictation', {'transcript': transcript}),
      );

  @override
  Future<RejectionFeedback> myRejections() async => RejectionFeedback.fromMap(
    await _send(() => http.Request('GET', Uri.parse('$_base/my-rejections'))),
  );

  @override
  Future<AssistantAnswer> askAssistant({
    required String question,
    List<AssistantTurn> history = const [],
    String? protocolId,
  }) async {
    final json = await _post('/assistant', {
      'question': question,
      'history': history.map((e) => e.toMap()).toList(),
      'protocol_id': protocolId,
    });
    return AssistantAnswer.fromMap(json);
  }

  // ------------------------------------------------------------------
  // HTTP
  // ------------------------------------------------------------------

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) =>
      _send(() {
        final req = http.Request('POST', Uri.parse('$_base$path'));
        req.headers['Content-Type'] = 'application/json';
        req.body = jsonEncode(body);
        return req;
      });

  /// Envía la petición (la arma [build], porque un reintento necesita una
  /// nueva) con el token de la sesión y renueva la sesión una vez si vence.
  Future<Map<String, dynamic>> _send(
    http.BaseRequest Function() build, {
    bool retried = false,
  }) async {
    http.Response res;
    try {
      final req = build();
      final token = await _token();
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';
      res = await http.Response.fromStream(
        await _client.send(req).timeout(timeout),
      );
    } on TimeoutException {
      throw const AiException(0);
    } catch (e) {
      developer.log('Error de red en IA', name: 'AI');
      throw const AiException(0);
    }

    if (res.statusCode == 401 && !retried && await _refresh()) {
      return _send(build, retried: true);
    }

    Map<String, dynamic> json = const {};
    try {
      final decoded = res.body.isEmpty
          ? null
          : jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map) json = Map<String, dynamic>.from(decoded);
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    throw AiException(res.statusCode, _detail(json['detail']));
  }

  /// `detail` puede ser texto o, en validaciones de FastAPI, una lista.
  static String? _detail(dynamic d) {
    if (d is String && d.trim().isNotEmpty) return d;
    if (d is List &&
        d.isNotEmpty &&
        d.first is Map &&
        (d.first as Map)['msg'] is String) {
      return (d.first as Map)['msg'] as String;
    }
    return null;
  }
}

/// Recorta la conversación a los últimos [max] mensajes que se mandan al
/// backend (el contrato pide 6 como máximo).
List<AssistantTurn> trimAssistantHistory(
  List<AssistantTurn> all, {
  int max = 6,
}) => [
  for (final t in all.length <= max ? all : all.sublist(all.length - max))
    t.content.length <= maxHistoryChars
        ? t
        : AssistantTurn(
            role: t.role,
            content: t.content.substring(0, maxHistoryChars),
          ),
];

/// Cada mensaje de la historia admite hasta 1000 caracteres.
const maxHistoryChars = 1000;
