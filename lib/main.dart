import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporter.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'firebase_options.dart';

/// точка входу: ініціалізує firebase, налаштовує crashlytics
/// і запускає кореневий віджет
Future<void> main() async {
  // потрібно перед будь-якими викликами платформного коду до runApp
  WidgetsFlutterBinding.ensureInitialized();

  // підключення до проєкту firebase з налаштувань,
  // які згенерував flutterfire configure
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final crashlytics = FirebaseCrashlytics.instance;

  // помилки, перехоплені фреймворком flutter (наприклад, під час build)
  FlutterError.onError = crashlytics.recordFlutterFatalError;

  // необроблені асинхронні помилки кореневого ізоляту поза flutter
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    crashlytics.recordError(error, stackTrace, fatal: true);
    return true; // помилку оброблено
  };

  // сервіси та репозиторій створюються один раз на весь застосунок
  final analytics = AnalyticsService(FirebaseAnalytics.instance);
  final crashReporter = CrashReporter(crashlytics);
  final authRepository = FirebaseAuthRepository(
    analytics: analytics,
    crashReporter: crashReporter,
  );

  runApp(
    AppDependencies(
      authRepository: authRepository,
      analytics: analytics,
      crashReporter: crashReporter,
      child: const GardenPlanApp(),
    ),
  );
}
