import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../data/models/app_user.dart';
import '../../main/main_shell.dart';
import 'login_screen.dart';

/// кореневий екран: слухає стан автентифікації firebase і показує
/// головний екран для користувача, що увійшов, або екран входу
/// завдяки цьому сеанс відновлюється після перезапуску застосунку
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AppUser?>? _subscription;
  AppUser? _user;
  bool _isLoaded = false; // чи прийшла перша подія від firebase

  @override
  void initState() {
    super.initState();
    _subscription = context.auth.userChanges().listen(_onUserChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel(); // відписуємось, щоб не було витоку памʼяті
    super.dispose();
  }

  void _onUserChanged(AppUser? user) {
    final isFirstEvent = !_isLoaded;
    final wasSignedIn = _user != null;
    final isSignedIn = user != null;

    setState(() {
      _user = user;
      _isLoaded = true;
    });

    if (isFirstEvent) {
      // перший запуск: firebase сам відновив збережений сеанс
      if (isSignedIn) {
        showAppSnackBar(context, 'Сеанс відновлено. Ви увійшли як ${user.email}');
      }
      context.analytics.logScreen(isSignedIn ? 'home' : 'login');
      return;
    }

    if (wasSignedIn != isSignedIn) {
      // вхід або вихід: прибираємо екрани, відкриті поверх
      // (реєстрація, профіль), і показуємо потрібний кореневий екран
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.analytics.logScreen(isSignedIn ? 'home' : 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const _SplashScreen();
    return _user == null ? const LoginScreen() : const MainShell();
  }
}

/// заставка, поки firebase перевіряє збережений сеанс
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 64, color: AppColors.primary),
            SizedBox(height: AppSpacing.medium),
            Text(
              'GardenPlan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.large),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
