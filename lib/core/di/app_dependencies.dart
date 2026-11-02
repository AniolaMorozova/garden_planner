import 'package:flutter/widgets.dart';

import '../../data/repositories/auth_repository.dart';
import '../services/analytics_service.dart';
import '../services/crash_reporter.dart';

/// робить репозиторій і сервіси доступними всім екранам
/// InheritedWidget лежить над MaterialApp, тому будь-який екран отримує їх
/// через AppDependencies.of(context) без передачі через конструктори
class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.authRepository,
    required this.analytics,
    required this.crashReporter,
    required super.child,
  });

  final AuthRepository authRepository;
  final AnalyticsService analytics;
  final CrashReporter crashReporter;

  static AppDependencies of(BuildContext context) {
    // get..., а не dependOn...: обʼєкти не змінюються, тож підписка на
    // оновлення не потрібна, і метод можна викликати в initState та колбеках
    final result = context.getInheritedWidgetOfExactType<AppDependencies>();
    assert(result != null, 'AppDependencies не знайдено над цим віджетом');
    return result!;
  }

  // обʼєкти створюються один раз у main, тому перебудова не потрібна
  @override
  bool updateShouldNotify(AppDependencies oldWidget) => false;
}

/// короткі геттери: context.auth, context.analytics, context.crash
extension AppDependenciesX on BuildContext {
  AuthRepository get auth => AppDependencies.of(this).authRepository;
  AnalyticsService get analytics => AppDependencies.of(this).analytics;
  CrashReporter get crash => AppDependencies.of(this).crashReporter;
}
