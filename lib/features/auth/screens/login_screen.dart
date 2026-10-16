import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/text_divider.dart';

/// екран входу
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // звільняємо ресурси контролерів, щоб не було витоку памʼяті
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// беку ше нема, того імітуємо успішну авторизацію і замінюєм!! екран входу головним (кнопка «назад» не поверне на вхід)
  void _onLoginPressed() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            // ConstrainedBox обмежує ширину форми на широких екранах
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                // stretch — дочірні віджети на всю ширину колонки
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Вхід',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Увійдіть, щоб продовжити планування',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Електронна пошта',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress, // клавіатура з @
                    textInputAction: TextInputAction.next, // «далі» → до пароля
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  PrimaryButton(
                    label: 'Увійти',
                    onPressed: _onLoginPressed,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      // pushNamed — кладемо екран ПОВЕРХ входу,
                      // «Назад» поверне сюди
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.forgotPassword),
                      child: const Text('Забули пароль?'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const TextDivider(text: 'або'),
                  const SizedBox(height: AppSpacing.medium),
                  SecondaryButton(
                    label: 'Створити обліковий запис',
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}