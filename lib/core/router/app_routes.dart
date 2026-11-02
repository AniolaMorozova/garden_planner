/// іменовані маршрути (адреси екранів) застосунку
/// тут лише назви, відповідність «назва → екран» в app.dart
abstract final class AppRoutes {
  /// стартовий маршрут: AuthGate сам показує вхід або головний екран
  static const String root = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
}
