import 'package:clinexa_derivant_app/core/services/speech_service.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:clinexa_derivant_app/data/repositories/fake_ai_repository.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// App mínima para probar pantallas de IA: tema del sistema, textos en
/// español y repositorio de IA falso.
Widget aiTestApp({
  required Widget child,
  required FakeAiRepository repo,
  SpeechService? speech,
  ProtocolRepository? protocols,
  bool dark = false,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AiRepository>.value(value: repo),
      RepositoryProvider<SpeechService>.value(
        value:
            speech ??
            FakeSpeechService(wordInterval: const Duration(milliseconds: 5)),
      ),
      RepositoryProvider<ProtocolRepository>.value(
        value: protocols ?? _NoProtocols(),
      ),
    ],
    child: BlocProvider(
      create: (_) => AiStatusCubit(repo),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('es'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: child,
      ),
    ),
  );
}

/// Sin fuentes por red en las pruebas.
void setUpAiWidgetTests() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
}

/// Avanza el tiempo en pasos (las animaciones neón son infinitas, así que
/// `pumpAndSettle` nunca termina).
Future<void> settle(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

class _NoProtocols implements ProtocolRepository {
  @override
  Future<ProtocolModel> getProtocolById(String id) async =>
      throw Exception('sin protocolos');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
