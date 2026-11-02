// інтеграційний тест: проходить основні сценарії лабораторної №4
// на реальному пристрої з реальним firebase і робить скриншоти для звіту
// запуск: scripts\lab4_run.ps1 (flutter test integration_test -d <емулятор>)
// тест друкує в лог позначку GP_SHOT:<назва>, а скрипт у цю мить
// знімає екран емулятора через adb screencap

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/app.dart';
import 'package:garden_planner/core/di/app_dependencies.dart';
import 'package:garden_planner/core/router/app_routes.dart';
import 'package:garden_planner/core/services/analytics_service.dart';
import 'package:garden_planner/core/services/crash_reporter.dart';
import 'package:garden_planner/data/repositories/firebase_auth_repository.dart';
import 'package:garden_planner/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // нова адреса на кожен запуск: лист для відновлення пароля
  // прийде у скриньку aniola.best.lviv@gmail.com
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'aniola.best.lviv+gp$stamp@gmail.com';
  const password = 'Garden2026';
  const newPassword = 'Sadivnyk2026';

  testWidgets('сценарії автентифікації GardenPlan', timeout: const Timeout(Duration(minutes: 15)), (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signOut(); // починаємо без сеансу
    // скрипт використає цей акаунт, щоб показати відновлення сеансу
    debugPrint('GP_ACCOUNT:$email');

    final analytics = AnalyticsService(FirebaseAnalytics.instance);
    final crashReporter = CrashReporter(FirebaseCrashlytics.instance);
    final auth = FirebaseAuthRepository(
      analytics: analytics,
      crashReporter: crashReporter,
    );

    await tester.pumpWidget(
      AppDependencies(
        authRepository: auth,
        analytics: analytics,
        crashReporter: crashReporter,
        child: const GardenPlanApp(),
      ),
    );

    var shotIndex = 0;

    /// просить скрипт зняти екран і тримає його незмінним ~3 секунди
    Future<void> shot(String name, {bool settle = true}) async {
      if (settle) await tester.pump(const Duration(milliseconds: 600));
      shotIndex++;
      final id = shotIndex.toString().padLeft(2, '0');
      debugPrint('GP_SHOT:${id}_$name');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    /// чекає, поки на екрані зʼявиться віджет (мережеві запити — реальні)
    /// якщо не дочекались — пишемо попередження і йдемо далі
    Future<bool> waitFor(Finder finder, {int seconds = 20}) async {
      final end = DateTime.now().add(Duration(seconds: seconds));
      while (finder.evaluate().isEmpty) {
        if (DateTime.now().isAfter(end)) {
          debugPrint('GP_WARN: not found $finder');
          return false;
        }
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 300));
      return true;
    }

    Future<void> tapText(String text) async {
      if (find.text(text).evaluate().isEmpty) {
        debugPrint('GP_WARN: no text to tap');
        return;
      }
      final finder = find.text(text).last;
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await tester.pump();
    }

    Finder field(String label) => find.widgetWithText(TextFormField, label);

    Future<void> enter(String label, String text) async {
      if (field(label).evaluate().isEmpty) return;
      await tester.ensureVisible(field(label));
      await tester.enterText(field(label), text);
      await tester.pump();
    }

    // ---------- 1. екран входу і локальна валідація ----------
    await waitFor(find.text('Увійдіть, щоб продовжити планування'));
    await shot('login');

    await tapText('Увійти');
    await waitFor(find.text('Введіть електронну пошту'));
    await shot('login_validation_empty');

    await enter('Електронна пошта', 'aniola@gmail');
    await enter('Пароль', '123');
    await tapText('Увійти');
    await waitFor(find.textContaining('Некоректний формат пошти'));
    await shot('login_validation_email');

    // ---------- 2. невдалий вхід (помилка від firebase) ----------
    await enter('Електронна пошта', 'nobody.gardenplan@gmail.com');
    await enter('Пароль', 'Wrong2026');
    await tapText('Увійти');
    await waitFor(find.text('Не вдалося увійти. Перевірте email і пароль'));
    await shot('login_failed');
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .hideCurrentSnackBar();

    // ---------- 3. реєстрація ----------
    await tapText('Створити обліковий запис');
    await waitFor(find.text('Створіть обліковий запис'));
    await shot('register');

    await enter('Імʼя та прізвище', 'A1');
    await enter('Електронна пошта', 'anna.example.com');
    await enter('Пароль', 'garden');
    await enter('Повторіть пароль', 'garden2');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText('Зареєструватися');
    await waitFor(find.text('Паролі не збігаються'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
    await tester.pump();
    await shot('register_validation');

    await enter('Імʼя та прізвище', 'Анна Морозова');
    await enter('Електронна пошта', email);
    await enter('Пароль', password);
    await enter('Повторіть пароль', password);
    await tapText('Зареєструватися');
    // стан завантаження: кнопка заблокована, крутиться індикатор
    await tester.pump(const Duration(milliseconds: 100));
    await shot('register_loading', settle: false);

    // ---------- 4. головний екран ----------
    await waitFor(find.text('Швидкі дії'));
    await shot('home_after_signup');

    await tester.tap(find.byType(Checkbox).at(1)); // подія garden_task_toggled
    await tester.pump();
    await tapText('Рослина'); // подія quick_action_tapped
    await tester.pump(const Duration(seconds: 1));

    // ---------- 5. профіль ----------
    Navigator.of(tester.element(find.text('Швидкі дії')))
        .pushNamed(AppRoutes.profile);
    await waitFor(find.text('Змінити пароль'));
    await shot('profile');

    await tapText('Редагувати профіль');
    await waitFor(find.text('Змінити фото'));

    await tapText('Змінити фото');
    await waitFor(find.text('Оберіть зображення'));
    await tester.pump(const Duration(seconds: 3)); // завантаження картинок
    final presets = find.descendant(
      of: find.byType(Wrap),
      matching: find.byType(CircleAvatar),
    );
    if (presets.evaluate().isNotEmpty) await tester.tap(presets.first);
    await tester.pump(const Duration(seconds: 2));
    await shot('photo_picker');
    await tapText('Застосувати');
    await tester.pump(const Duration(seconds: 2));
    await shot('edit_profile_new_photo');

    await tapText('Зберегти');
    await waitFor(find.text('Зміни збережено'));
    await tester.pump(const Duration(seconds: 2));
    await shot('profile_updated');

    // ---------- 6. зміна пароля ----------
    await tapText('Змінити пароль');
    await waitFor(find.text('Поточний пароль'));
    await enter('Поточний пароль', 'Wrong2026');
    await enter('Новий пароль', newPassword);
    await enter('Повторіть новий пароль', newPassword);
    await tapText('Змінити пароль');
    await waitFor(find.text('Поточний пароль неправильний'));
    await shot('change_password_wrong_current');

    await enter('Поточний пароль', password);
    await tapText('Змінити пароль');
    if (await waitFor(find.text('Пароль змінено'))) {
      debugPrint('GP_PASSWORD_CHANGED');
    }
    await shot('password_changed');

    // ---------- 7. тестова помилка crashlytics ----------
    await tester.tap(find.byTooltip('Більше'));
    await tester.pumpAndSettle();
    await tapText('Тест Crashlytics');
    await waitFor(find.text('Нефатальна помилка'));
    await shot('crashlytics_dialog');
    await tapText('Нефатальна помилка');
    await waitFor(find.text('Тестову помилку надіслано в Crashlytics'));
    await shot('crashlytics_sent');

    // ---------- 8. вихід ----------
    await tapText('Вийти з облікового запису');
    await waitFor(find.text('Ви вийшли з облікового запису'));
    await shot('logout');

    // ---------- 9. повторна реєстрація з тією ж поштою ----------
    await tapText('Створити обліковий запис');
    await waitFor(find.text('Створіть обліковий запис'));
    await enter('Імʼя та прізвище', 'Анна Морозова');
    await enter('Електронна пошта', email);
    await enter('Пароль', password);
    await enter('Повторіть пароль', password);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText('Зареєструватися');
    await waitFor(find.text('Обліковий запис з такою поштою вже існує'));
    await shot('register_email_in_use');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---------- 10. відновлення пароля ----------
    await enter('Електронна пошта', email);
    await tapText('Забули пароль?');
    await waitFor(find.text('Надіслати посилання'));
    await shot('forgot_password');
    await tapText('Надіслати посилання');
    await waitFor(find.text('Перевірте пошту'));
    await shot('forgot_password_sent');
    await tapText('Повернутись до входу');
    await tester.pumpAndSettle();

    // ---------- 11. вхід з новим паролем ----------
    await enter('Електронна пошта', email);
    await enter('Пароль', newPassword);
    await tapText('Увійти');
    await waitFor(find.text('Швидкі дії'));
    await shot('login_success');
    // сеанс лишається активним: після перезапуску застосунку
    // AuthGate відновить його (скриншот робить скрипт через adb)
  });
}
