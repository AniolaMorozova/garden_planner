import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// тестовий виняток, щоб у firebase crashlytics його було легко знайти
class CrashlyticsTestException implements Exception {
  const CrashlyticsTestException(this.message);

  final String message;

  @override
  String toString() => 'CrashlyticsTestException: $message';
}

/// обгортка над firebase crashlytics
class CrashReporter {
  CrashReporter(FirebaseCrashlytics crashlytics) : _crashlytics = crashlytics;

  /// версія без firebase (для тестів)
  const CrashReporter.disabled() : _crashlytics = null;

  final FirebaseCrashlytics? _crashlytics;

  /// нефатальна помилка: застосунок її обробив і працює далі
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
  }) async =>
      _crashlytics?.recordError(error, stackTrace, reason: reason, fatal: false);

  /// діагностичне повідомлення в журнал наступного звіту
  /// (сам звіт не створює; паролі й токени сюди не пишемо)
  Future<void> log(String message) async => _crashlytics?.log(message);

  /// привʼязуємо звіти до користувача (лише uid, без пошти)
  Future<void> setUser(String? uid) async =>
      _crashlytics?.setUserIdentifier(uid ?? '');

  /// генерує тестову нефатальну помилку для перевірки інтеграції
  Future<void> sendTestNonFatal() async {
    await log('Натиснуто «Надіслати тестову помилку» у профілі');
    try {
      throw const CrashlyticsTestException(
        'Тестова нефатальна помилка GardenPlan (лабораторна №4)',
      );
    } catch (error, stackTrace) {
      await recordNonFatal(
        error,
        stackTrace,
        reason: 'Перевірка інтеграції Crashlytics',
      );
    }
  }

  /// аварійно завершує застосунок, звіт надійде після наступного запуску
  void testCrash() => _crashlytics?.crash();
}
