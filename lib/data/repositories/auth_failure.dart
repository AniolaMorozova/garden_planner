/// помилка автентифікації з зрозумілим користувачу текстом
/// репозиторій перетворює FirebaseAuthException на AuthFailure,
/// тому екрани не залежать від firebase і не показують технічний текст
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  /// код помилки firebase, наприклад 'email-already-in-use'
  final String code;

  /// повідомлення українською для snackbar або підпису під полем
  final String message;

  /// чи потрібно повторно увійти (для зміни пароля)
  bool get requiresRecentLogin => code == 'requires-recent-login';

  /// помилка стосується саме пошти (показуємо під полем пошти)
  bool get isEmailError =>
      code == 'email-already-in-use' || code == 'invalid-email';

  /// неправильні дані входу або поточний пароль
  bool get isWrongCredentials =>
      code == 'invalid-credential' ||
      code == 'wrong-password' ||
      code == 'user-not-found' ||
      code == 'INVALID_LOGIN_CREDENTIALS';

  /// перетворює код firebase на повідомлення українською
  factory AuthFailure.fromCode(String code) {
    final message = switch (code) {
      'invalid-email' => 'Некоректний формат електронної пошти',
      'user-disabled' => 'Обліковий запис заблоковано. Зверніться до підтримки',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        'Не вдалося увійти. Перевірте email і пароль',
      'email-already-in-use' => 'Обліковий запис з такою поштою вже існує',
      'weak-password' =>
        'Пароль занадто простий: мінімум 8 символів, літери та цифри',
      'password-does-not-meet-requirements' =>
        'Пароль не відповідає вимогам безпеки',
      'too-many-requests' =>
        'Забагато спроб. Зачекайте кілька хвилин і спробуйте знову',
      'network-request-failed' =>
        'Немає зʼєднання з інтернетом. Перевірте мережу',
      'requires-recent-login' =>
        'З міркувань безпеки потрібно увійти в обліковий запис ще раз',
      'operation-not-allowed' => 'Цей спосіб входу вимкнено в налаштуваннях',
      'no-current-user' => 'Сеанс завершився. Увійдіть знову',
      _ => 'Щось пішло не так. Спробуйте ще раз',
    };
    return AuthFailure(code, message);
  }

  @override
  String toString() => 'AuthFailure($code): $message';
}
