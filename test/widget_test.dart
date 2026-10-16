import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/app.dart';

void main() {
  testWidgets('застосунок відкривається з екрана входу', (tester) async {
    await tester.pumpWidget(const GardenPlanApp());

    expect(find.text('Вхід'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });

  testWidgets('кнопка увійти відкриває головний екран', (tester) async {
    await tester.pumpWidget(const GardenPlanApp());

    // прокручуємо до кнопки, бо в тестовому вікні вона може бути нижче
    await tester.ensureVisible(find.text('Увійти'));
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle(); // чекаємо поки завершиться анімація переходу

    expect(find.text('Швидкі дії'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}