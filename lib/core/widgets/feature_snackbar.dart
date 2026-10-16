import 'package:flutter/material.dart';

/// показує коротке повідомлення внизу екрана
void showAppSnackBar(BuildContext context, String message) {
  // ScaffoldMessenger керує показом snackbar-ів у застосунку.
  // .. (каскадний оператор) — викликаємо два методи на одному обʼєкті.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // ховаємо попереднє, якщо було
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// повідомлення для функцій, які буде реалізовано в наступних лабораторних
void showNotImplemented(BuildContext context, String feature) {
  showAppSnackBar(context, '«$feature» буде доступно в наступних версіях');
}