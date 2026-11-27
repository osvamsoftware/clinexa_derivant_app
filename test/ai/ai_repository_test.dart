import 'dart:convert';
import 'dart:typed_data';

import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Respuestas tomadas del contrato (clinexa_backend/docs/IA_APPS_CONTRATO.md).
const _base = 'https://api.test/api/ai/app';

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late List<http.BaseRequest> requests;
  late List<String> bodies;

  AiRepositoryImpl repo(
    Future<http.Response> Function(http.Request r) handler, {
    Future<bool> Function()? refresh,
    String token = 'tok-1',
  }) {
    requests = [];
    bodies = [];
    return AiRepositoryImpl(
      baseUrl: _base,
      client: MockClient((r) {
        requests.add(r);
        bodies.add(r.body);
        return handler(r);
      }),
      tokenProvider: () async => token,
      refreshSession: refresh ?? () async => false,
    );
  }

  group('status', () {
    test('lee enabled y mode, y lo cachea en memoria', () async {
      final r = repo((_) async => _json({'enabled': true, 'mode': 'live'}));
      final a = await r.status();
      final b = await r.status();
      expect(a, const AiStatus(enabled: true, mode: 'live'));
      expect(b.enabled, isTrue);
      expect(requests, hasLength(1));
      expect(requests.single.url.toString(), '$_base/status');
      expect(requests.single.headers['Authorization'], 'Bearer tok-1');
    });

    test('404 (backend sin rutas de IA) = desactivada y cacheada', () async {
      final r = repo((_) async => _json({'detail': 'Not Found'}, 404));
      expect((await r.status()).enabled, isFalse);
      expect((await r.status()).enabled, isFalse);
      expect(requests, hasLength(1));
    });

    test('enabled false oculta la IA', () async {
      final r = repo((_) async => _json({'enabled': false, 'mode': 'live'}));
      expect((await r.status()).enabled, isFalse);
    });

    test('sin red: desactivada, pero se reintenta la próxima vez', () async {
      final r = repo((_) async => throw http.ClientException('sin red'));
      expect((await r.status()).enabled, isFalse);
      await r.status();
      expect(requests, hasLength(2));
    });
  });

  test('eligibility: envía el caso y lee la respuesta', () async {
    final r = repo(
      (_) async => _json({
        'eligibility_id': 'e1',
        'usage_id': 'u1',
        'mode': 'live',
        'protocol_id': 'p1',
        'protocol_name': 'DM2-OPT',
        'fit_score': 82,
        'summary': 'Cumple casi todo.',
        'items': [
          {
            'order': 1,
            'text': 'Edad 40-75',
            'kind': 'inclusion',
            'status': 'meets',
            'evidence': '58 años',
          },
          {
            'order': 2,
            'text': 'Insulina',
            'kind': 'exclusion',
            'status': 'fails',
            'evidence': 'NPH',
          },
          {
            'order': 3,
            'text': 'TFG',
            'kind': 'inclusion',
            'status': 'missing',
            'evidence': '',
          },
        ],
      }),
    );
    final res = await r.evaluateEligibility(
      protocolId: 'p1',
      aiCase: const AiCase(
        age: 58,
        sex: 'female',
        pathologies: ['Diabetes tipo 2'],
        notes: 'HbA1c 8.2 %',
      ),
    );
    expect(requests.single.method, 'POST');
    expect(requests.single.url.toString(), '$_base/eligibility');
    expect(jsonDecode(bodies.single), {
      'protocol_id': 'p1',
      'case': {
        'age': 58,
        'sex': 'female',
        'pathologies': ['Diabetes tipo 2'],
        'notes': 'HbA1c 8.2 %',
      },
    });
    expect(res.eligibilityId, 'e1');
    expect(res.fitScore, 82);
    expect(res.items.map((e) => e.status), [
      EligibilityStatus.meets,
      EligibilityStatus.fails,
      EligibilityStatus.missing,
    ]);
    expect(res.items[1].isExclusion, isTrue);
  });

  test('attach: manda patient_id y las correcciones del médico', () async {
    final r = repo((_) async => _json({'ok': true}));
    await r.attachEligibility(
      eligibilityId: 'e1',
      patientId: 'pac-9',
      reviewed: {1: EligibilityStatus.meets, 2: EligibilityStatus.missing},
    );
    expect(requests.single.url.toString(), '$_base/eligibility/e1/attach');
    expect(jsonDecode(bodies.single), {
      'patient_id': 'pac-9',
      'reviewed_items': [
        {'order': 1, 'status': 'meets'},
        {'order': 2, 'status': 'missing'},
      ],
    });
  });

  test('suggest-protocols', () async {
    final r = repo(
      (_) async => _json({
        'usage_id': 'u',
        'mode': 'live',
        'suggestions': [
          {
            'protocol_id': 'p1',
            'name': 'DM2-OPT',
            'score': 87,
            'reason': 'Encaja',
            'specialties': ['Endocrinología'],
            'pathologies': ['Diabetes tipo 2'],
          },
        ],
        'note': 'Solo activos',
      }),
    );
    final res = await r.suggestProtocols('mujer de 58 años, DM2');
    expect(jsonDecode(bodies.single), {'description': 'mujer de 58 años, DM2'});
    expect(res.suggestions.single.score, 87);
    expect(res.suggestions.single.specialties, ['Endocrinología']);
    expect(res.note, 'Solo activos');
  });

  test('extract-document: multipart con el campo file', () async {
    late http.Request captured;
    requests = [];
    final r = AiRepositoryImpl(
      baseUrl: _base,
      tokenProvider: () async => 'tok',
      client: MockClient((req) async {
        captured = req;
        return _json({
          'usage_id': 'u',
          'mode': 'live',
          'findings': [
            {
              'label': 'HbA1c',
              'value': '8.2',
              'unit': '%',
              'date': '2026-11-10',
            },
          ],
          'notes_text': 'HbA1c 8.2 % (10/11/2026)',
          'warnings': ['Revisa la fecha'],
        });
      }),
    );
    final res = await r.extractDocument(
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'estudio.jpg',
      mimeType: 'image/jpeg',
    );
    expect(captured.url.toString(), '$_base/extract-document');
    expect(captured.headers['content-type'], startsWith('multipart/form-data'));
    final raw = latin1.decode(captured.bodyBytes);
    expect(raw, contains('name="file"; filename="estudio.jpg"'));
    expect(raw, contains('content-type: image/jpeg'));
    expect(res.findings.single.label, 'HbA1c');
    expect(res.notesText, 'HbA1c 8.2 % (10/11/2026)');
    expect(res.warnings, ['Revisa la fecha']);
  });

  test('parse-dictation nunca trae identidad: solo los 4 campos', () async {
    final r = repo(
      (_) async => _json({
        'usage_id': 'u',
        'mode': 'live',
        'fields': {
          'age': 58,
          'sex': 'female',
          'pathologies': ['DM2'],
          'notes': 'HbA1c 8.2',
        },
        'warnings': ['Se omitió el nombre'],
      }),
    );
    final f = await r.parseDictation('mujer de 58…');
    expect(jsonDecode(bodies.single), {'transcript': 'mujer de 58…'});
    expect(f.age, 58);
    expect(f.sex, 'female');
    expect(f.pathologies, ['DM2']);
    expect(f.notes, 'HbA1c 8.2');
    expect(f.warnings, ['Se omitió el nombre']);
  });

  test(
    'my-rejections con total (el cliente general lo confundía con una lista)',
    () async {
      final r = repo(
        (_) async => _json({
          'usage_id': 'u',
          'mode': 'live',
          'total': 4,
          'summary': 'Resumen',
          'created_at': '2026-11-20T10:00:00Z',
          'categories': [
            {
              'name': 'Faltan estudios',
              'count': 2,
              'protocols': ['DM2-OPT'],
              'recommendation': 'Agrega HbA1c',
            },
          ],
        }),
      );
      final res = await r.myRejections();
      expect(requests.single.method, 'GET');
      expect(res.total, 4);
      expect(res.categories.single.count, 2);
      expect(res.createdAt, isNotNull);
    },
  );

  test('assistant: pregunta, historia y protocol_id', () async {
    final r = repo(
      (_) async => _json({
        'usage_id': 'u',
        'mode': 'live',
        'answer': 'Dos protocolos.',
        'sources': [
          {
            'protocol_id': 'p1',
            'protocol_name': 'DM2-OPT',
            'excerpt': 'TFG ≥ 45',
          },
        ],
        'follow_ups': ['¿Y en diálisis?'],
      }),
    );
    final a = await r.askAssistant(
      question: '¿Cuáles aceptan IRC?',
      history: const [
        AssistantTurn(role: 'user', content: 'Hola'),
        AssistantTurn(role: 'assistant', content: '¿En qué te ayudo?'),
      ],
      protocolId: 'p1',
    );
    expect(jsonDecode(bodies.single), {
      'question': '¿Cuáles aceptan IRC?',
      'history': [
        {'role': 'user', 'content': 'Hola'},
        {'role': 'assistant', 'content': '¿En qué te ayudo?'},
      ],
      'protocol_id': 'p1',
    });
    expect(a.answer, 'Dos protocolos.');
    expect(a.sources.single.excerpt, 'TFG ≥ 45');
    expect(a.followUps, ['¿Y en diálisis?']);
  });

  group('errores', () {
    for (final code in [400, 403, 404, 429, 502, 503]) {
      test('$code: conserva el detail del backend tal cual', () async {
        final r = repo(
          (_) async => _json({'detail': 'Mensaje $code en español.'}, code),
        );
        await expectLater(
          r.suggestProtocols('x'),
          throwsA(
            isA<AiException>()
                .having((e) => e.statusCode, 'statusCode', code)
                .having((e) => e.detail, 'detail', 'Mensaje $code en español.'),
          ),
        );
      });
    }

    test('sin red: código 0 y sin detail', () async {
      final r = repo((_) async => throw http.ClientException('sin red'));
      await expectLater(
        r.myRejections(),
        throwsA(
          isA<AiException>()
              .having((e) => e.statusCode, 'statusCode', 0)
              .having((e) => e.detail, 'detail', isNull),
        ),
      );
    });

    test('401: renueva la sesión una vez y reintenta', () async {
      var calls = 0;
      var refreshed = 0;
      final r = repo(
        (_) async => ++calls == 1
            ? _json({'detail': 'Token vencido'}, 401)
            : _json({'enabled': true, 'mode': 'live'}),
        refresh: () async {
          refreshed++;
          return true;
        },
      );
      expect((await r.status()).enabled, isTrue);
      expect(calls, 2);
      expect(refreshed, 1);
    });
  });

  test('trimAssistantHistory deja los últimos 6 mensajes', () {
    final all = [
      for (var i = 0; i < 9; i++)
        AssistantTurn(role: i.isEven ? 'user' : 'assistant', content: '$i'),
    ];
    final trimmed = trimAssistantHistory(all);
    expect(trimmed, hasLength(6));
    expect(trimmed.first.content, '3');
    expect(trimmed.last.content, '8');
  });
}
