import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// показує коротке повідомлення внизу екрана
/// [isError] — червоний фон для повідомлень про помилки
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  // ScaffoldMessenger керує показом snackbar-ів у застосунку.
  // .. (каскадний оператор) — викликаємо два методи на одному обʼєкті.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // ховаємо попереднє, якщо було
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
}

/// повідомлення для функцій, які буде реалізовано в наступних лабораторних
void showNotImplemented(BuildContext context, String feature) {
  showAppSnackBar(context, '«$feature» буде доступно в наступних версіях');
}
