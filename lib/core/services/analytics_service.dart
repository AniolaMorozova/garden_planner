import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// обгортка над firebase analytics
/// екрани не звертаються до firebase напряму, а викликають ці методи,
/// тому в тестах можна передати AnalyticsService.disabled() без firebase
class AnalyticsService {
  AnalyticsService(FirebaseAnalytics analytics) : _analytics = analytics;

  /// версія без firebase (для тестів): усі методи нічого не роблять
  const AnalyticsService.disabled() : _analytics = null;

  final FirebaseAnalytics? _analytics;

  /// спостерігач навігатора: логує screen_view при переходах між
  /// іменованими маршрутами (назва маршруту стає назвою екрана)
  List<NavigatorObserver> get navigatorObservers => [
        if (_analytics != null) FirebaseAnalyticsObserver(analytics: _analytics),
      ];

  /// ручний screen_view для екранів без окремого маршруту
  /// (вкладки нижньої панелі, екран входу всередині AuthGate)
  Future<void> logScreen(String screenName) async =>
      _analytics?.logScreenView(screenName: screenName);

  // ---- рекомендовані події firebase ----

  Future<void> logLogin() async => _analytics?.logLogin(loginMethod: 'email');

  Future<void> logSignUp() async =>
      _analytics?.logSignUp(signUpMethod: 'email');

  // ---- власні події застосунку ----

  Future<void> logLogout() async => _analytics?.logEvent(name: 'logout');

  Future<void> logPasswordResetRequested() async =>
      _analytics?.logEvent(name: 'password_reset_requested');

  Future<void> logPasswordChanged() async =>
      _analytics?.logEvent(name: 'password_changed');

  Future<void> logProfileUpdated({required bool photoChanged}) async =>
      _analytics?.logEvent(
        name: 'profile_updated',
        parameters: {'photo_changed': photoChanged ? 'yes' : 'no'},
      );

  /// користувач поставив або зняв галочку на роботі (FR-09)
  Future<void> logTaskToggled({
    required String taskType,
    required bool isDone,
  }) async =>
      _analytics?.logEvent(
        name: 'garden_task_toggled',
        parameters: {'task_type': taskType, 'is_done': isDone ? 'yes' : 'no'},
      );

  /// натискання на кнопку з блоку «Швидкі дії» (FR-05)
  Future<void> logQuickAction(String action) async => _analytics?.logEvent(
        name: 'quick_action_tapped',
        parameters: {'action': action},
      );
}
