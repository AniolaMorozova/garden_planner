import 'dart:async';

import 'package:garden_planner/data/models/app_user.dart';
import 'package:garden_planner/data/repositories/auth_failure.dart';
import 'package:garden_planner/data/repositories/auth_repository.dart';

/// фейковий репозиторій для тестів: зберігає користувачів у памʼяті
/// і поводиться як firebase auth, але без мережі
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  final Map<String, String> _passwords = {'anna@example.com': 'garden123'};
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> userChanges() async* {
    yield _user; // як і firebase: одразу віддаємо поточний стан
    yield* _controller.stream;
  }

  void _emit(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (_passwords[email.trim()] != password) {
      throw AuthFailure.fromCode('invalid-credential');
    }
    _emit(AppUser(uid: 'u1', fullName: 'Анна Морозова', email: email.trim()));
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_passwords.containsKey(email.trim())) {
      throw AuthFailure.fromCode('email-already-in-use');
    }
    _passwords[email.trim()] = password;
    _emit(AppUser(uid: 'u2', fullName: name.trim(), email: email.trim()));
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> updateProfile({required String name, String? photoUrl}) async {
    final user = _user!;
    _emit(AppUser(
      uid: user.uid,
      fullName: name.trim(),
      email: user.email,
      photoUrl: photoUrl,
    ));
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _user!.email;
    if (_passwords[email] != currentPassword) {
      throw AuthFailure.fromCode('invalid-credential');
    }
    _passwords[email] = newPassword;
  }

  @override
  Future<void> signOut() async => _emit(null);
}
