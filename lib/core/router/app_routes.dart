/// іменовані маршрути (адреси екранів) застосунку
/// тут лише назви, відповідність «назва → екран» в app.dart
abstract final class AppRoutes {
  static const String login = '/'; // стартовий екран
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
}