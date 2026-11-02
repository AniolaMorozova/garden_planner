import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/crash_reporter.dart';
import '../mock/mock_data.dart';
import '../models/app_user.dart';
import 'auth_failure.dart';
import 'auth_repository.dart';

/// реалізація AuthRepository через firebase authentication
/// уся взаємодія з firebase auth зібрана тут, екрани її не бачать
class FirebaseAuthRepository implements AuthRepository {
  // this._analytics — приватний іменований параметр: при виклику
  // пишемо analytics: ..., а значення одразу потрапляє в поле _analytics
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    required this._analytics,
    required this._crashReporter,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final AnalyticsService _analytics;
  final CrashReporter _crashReporter;

  // ---------- стан користувача ----------

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  /// перетворюємо User з firebase на модель застосунку
  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      // статистика — заглушка, реальні дані будуть з cloud firestore
      plotsCount: MockData.stats.plots,
      plantsCount: MockData.stats.plants,
      tasksCount: MockData.stats.tasks,
    );
  }

  // ---------- реєстрація, вхід, вихід ----------

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard('signUp', () async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        // імʼя зберігаємо в профілі firebase auth
        await credential.user?.updateDisplayName(name.trim());
        // reload, щоб currentUser і userChanges отримали нове імʼя
        await credential.user?.reload();
        await _crashReporter.setUser(credential.user?.uid);
        await _analytics.logSignUp();
      });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard('signIn', () async {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await _crashReporter.setUser(credential.user?.uid);
        await _analytics.logLogin();
      });

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _guard('sendPasswordResetEmail', () async {
        await _auth.setLanguageCode('uk'); // лист українською
        await _auth.sendPasswordResetEmail(email: email.trim());
        await _analytics.logPasswordResetRequested();
      });

  @override
  Future<void> signOut() => _guard('signOut', () async {
        await _auth.signOut();
        await _crashReporter.setUser(null);
        await _analytics.logLogout();
      });

  // ---------- профіль ----------

  @override
  Future<void> updateProfile({required String name, String? photoUrl}) =>
      _guard('updateProfile', () async {
        final user = _requireUser();
        final photoChanged = photoUrl != user.photoURL;
        if (name.trim() != (user.displayName ?? '')) {
          await user.updateDisplayName(name.trim());
        }
        // updatePhotoURL зберігає лише посилання, файл не завантажує
        if (photoChanged) await user.updatePhotoURL(photoUrl);
        await user.reload();
        await _analytics.logProfileUpdated(photoChanged: photoChanged);
      });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _guard('changePassword', () async {
        final user = _requireUser();
        final credential = EmailAuthProvider.credential(
          email: user.email ?? '',
          password: currentPassword,
        );
        // повторне підтвердження особи: перевіряє поточний пароль і
        // оновлює час входу, тому updatePassword не поверне
        // requires-recent-login
        await user.reauthenticateWithCredential(credential);
        try {
          await user.updatePassword(newPassword);
        } on FirebaseAuthException catch (e) {
          if (e.code != 'requires-recent-login') rethrow;
          // рідкісний випадок: сеанс застарів між двома запитами —
          // ще раз підтверджуємо особу й повторюємо операцію
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPassword);
        }
        await _analytics.logPasswordChanged();
      });

  // ---------- допоміжне ----------

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('no-current-user', '');
    return user;
  }

  /// виконує дію і перетворює помилки firebase на AuthFailure
  /// очікувані помилки (неправильний пароль тощо) не відправляємо в
  /// crashlytics, а неочікувані — реєструємо як нефатальні
  Future<void> _guard(String operation, Future<void> Function() action) async {
    try {
      await _crashReporter.log('auth: $operation');
      await action();
    } on AuthFailure catch (e) {
      throw AuthFailure.fromCode(e.code);
    } on FirebaseAuthException catch (e, stackTrace) {
      final failure = AuthFailure.fromCode(e.code);
      if (failure.message == AuthFailure.fromCode('unknown').message) {
        await _crashReporter.recordNonFatal(e, stackTrace,
            reason: 'Неочікувана помилка Firebase Auth: $operation');
      }
      throw failure;
    } catch (e, stackTrace) {
      await _crashReporter.recordNonFatal(e, stackTrace,
          reason: 'Неочікувана помилка під час $operation');
      throw AuthFailure.fromCode('unknown');
    }
  }
}
