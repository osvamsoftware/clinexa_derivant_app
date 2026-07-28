import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/presentation/managers/manager_provider.dart';
import 'package:clinexa_derivant_app/presentation/managers/manager_repository.dart';
import 'package:clinexa_derivant_app/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:clinexa_derivant_app/firebase_options.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/data/repositories/notification_repository_impl.dart';

import 'dart:ui' as ui;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:clinexa_derivant_app/core/helpers/localization_helper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final locale = ui.PlatformDispatcher.instance.locale;
  final s = await S.delegate.load(locale);

  final notificationModel = NotificationModel.fromRemoteMessage(message);

  final title = LocalizationHelper.translateNotificationKey(
    s,
    notificationModel.title,
    notificationModel.data,
  );
  final body = LocalizationHelper.translateNotificationKey(
    s,
    notificationModel.body,
    notificationModel.data,
  );

  if (title.isNotEmpty || body.isNotEmpty) {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await localNotificationsPlugin.show(
      notificationModel.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones Importantes',
          channelDescription:
              'Canal usado para notificaciones importantes en primer plano.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SharedPrefsService.instance.init();

  // La configuración llega por --dart-define en tiempo de compilación.
  // Antes venía de un .env empaquetado como asset dentro del APK.
  AppConfig.assertValid();

  final api = await createApiInstance();

  // Initialize ApiService with the correct base URL
  ApiService().setBaseUrl(api.baseUrl);

  // Notification Service Setup
  final notificationRepo = NotificationRepositoryImpl(api: api);
  final notificationService = NotificationService(repository: notificationRepo);
  await notificationService.initListeners();

  runApp(ClinexaApp(api: api, notificationService: notificationService));
}

class ClinexaApp extends StatelessWidget {
  final Api api;
  final NotificationService notificationService;

  const ClinexaApp({
    super.key,
    required this.api,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return ManagerRepository(
      api: api,
      notificationService: notificationService,
      child: Builder(
        builder: (context) {
          return ManagerProvider(
            child: MaterialApp.router(
              title: 'Clinexa',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              theme: AppTheme.lightTheme,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('es')],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return const Locale('en');
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
                return const Locale('en');
              },
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
