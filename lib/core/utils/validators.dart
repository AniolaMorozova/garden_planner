import 'package:flutter/widgets.dart';

/// локальна валідація полів форм
/// кожен метод повертає текст помилки або null, якщо значення коректне
/// (так працює TextFormField.validator)
/// перевіряється лише формат: існування акаунта і правильність пароля
/// перевіряє firebase auth уже після надсилання запиту
abstract final class Validators {
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // name@example.com: частина до @, домен з крапкою і зона з 2+ літер
  static final RegExp _emailRegExp =
      RegExp(r'^[\w.+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,}$');
  static final RegExp _letterRegExp = RegExp(r'[A-Za-zА-Яа-яЇїІіЄєҐґ]');
  static final RegExp _digitRegExp = RegExp(r'\d');
  // літери (латиниця, кирилиця), пробіл, апостроф і дефіс: «Анна-Марія Дʼяченко»
  static final RegExp _nameRegExp =
      RegExp(r"^[A-Za-zА-Яа-яЇїІіЄєҐґ'ʼ’\- ]+$");

  static bool hasMinLength(String value) => value.length >= minPasswordLength;

  static bool hasLettersAndDigits(String value) =>
      _letterRegExp.hasMatch(value) && _digitRegExp.hasMatch(value);

  /// імʼя та прізвище: обовʼязкове, 2–50 символів, лише літери
  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введіть імʼя';
    if (text.length < minNameLength) return 'Імʼя занадто коротке';
    if (text.length > maxNameLength) {
      return 'Не більше $maxNameLength символів';
    }
    if (!_nameRegExp.hasMatch(text)) {
      return 'Імʼя може містити лише літери, пробіл, дефіс та апостроф';
    }
    return null;
  }

  /// електронна пошта: обовʼязкова і має правильний формат
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введіть електронну пошту';
    if (!_emailRegExp.hasMatch(text)) {
      return 'Некоректний формат пошти, наприклад name@example.com';
    }
    return null;
  }

  /// пароль на екрані входу: лише обовʼязковість
  /// (вимоги до складності перевіряти тут не можна — старі паролі могли бути
  /// створені за іншими правилами)
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Введіть пароль' : null;

  /// новий пароль: мінімум 8 символів, літери та цифри (FR-01, FR-04)
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Введіть пароль';
    if (text.contains(' ')) return 'Пароль не може містити пробіли';
    if (!hasMinLength(text)) {
      return 'Мінімум $minPasswordLength символів';
    }
    if (!hasLettersAndDigits(text)) return 'Пароль має містити літери та цифри';
    return null;
  }

  /// повтор пароля має збігатися з паролем з іншого поля
  static FormFieldValidator<String> repeatPassword(
    TextEditingController passwordController,
  ) =>
      (value) {
        if (value == null || value.isEmpty) return 'Повторіть пароль';
        if (value != passwordController.text) return 'Паролі не збігаються';
        return null;
      };

  /// посилання на фото: обовʼязкове, лише https
  static String? httpsImageUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Вставте посилання на зображення';
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasAuthority) return 'Некоректне посилання';
    if (uri.scheme != 'https') return 'Посилання має починатися з https://';
    return null;
  }
}
