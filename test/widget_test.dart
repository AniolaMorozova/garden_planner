import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/app.dart';
import 'package:garden_planner/core/di/app_dependencies.dart';
import 'package:garden_planner/core/services/analytics_service.dart';
import 'package:garden_planner/core/services/crash_reporter.dart';
import 'package:garden_planner/core/utils/validators.dart';

import 'fake_auth_repository.dart';

/// застосунок із фейковим репозиторієм замість firebase
Widget buildTestApp(FakeAuthRepository auth) => AppDependencies(
      authRepository: auth,
      analytics: const AnalyticsService.disabled(),
      crashReporter: const CrashReporter.disabled(),
      child: const GardenPlanApp(),
    );

void main() {
  group('Validators', () {
    test('пошта', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('anna@'), isNotNull);
      expect(Validators.email('anna@example.com'), isNull);
    });

    test('новий пароль', () {
      expect(Validators.newPassword('short1'), isNotNull); // < 8
      expect(Validators.newPassword('onlyletters'), isNotNull); // без цифр
      expect(Validators.newPassword('garden123'), isNull);
    });

    test('імʼя', () {
      expect(Validators.name(' '), isNotNull);
      expect(Validators.name('Анна Морозова'), isNull);
      expect(Validators.name('Anna1'), isNotNull);
    });
  });

  testWidgets('без сеансу відкривається екран входу', (tester) async {
    await tester.pumpWidget(buildTestApp(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Вхід'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });

  testWidgets('порожня форма входу показує помилки валідації', (tester) async {
    await tester.pumpWidget(buildTestApp(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Увійти'));
    await tester.tap(find.text('Увійти'));
    await tester.pump();

    expect(find.text('Введіть електронну пошту'), findsOneWidget);
    expect(find.text('Введіть пароль'), findsOneWidget);
  });

  testWidgets('неправильний пароль показує зрозуміле повідомлення',
      (tester) async {
    await tester.pumpWidget(buildTestApp(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'anna@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong999');
    await tester.ensureVisible(find.text('Увійти'));
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(
      find.text('Не вдалося увійти. Перевірте email і пароль'),
      findsWidgets,
    );
    expect(find.text('Швидкі дії'), findsNothing);
  });

  testWidgets('правильні дані відкривають головний екран', (tester) async {
    await tester.pumpWidget(buildTestApp(FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'anna@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'garden123');
    await tester.ensureVisible(find.text('Увійти'));
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Швидкі дії'), findsOneWidget);
    expect(find.text('Привіт, Анно!'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
