import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/text_divider.dart';
import '../../../data/repositories/auth_failure.dart';

/// екран входу (FR-02)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ключ форми створюємо один раз у стані, а не в build()
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // йде запит до firebase
  String? _credentialsError; // помилка від сервера під полем пароля

  // звільняємо ресурси контролерів, щоб не було витоку памʼяті
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus(); // ховаємо клавіатуру
    setState(() => _credentialsError = null);

    // 1. локальна валідація: формат пошти і непорожній пароль
    if (!_formKey.currentState!.validate()) return;

    // messenger беремо до await: після входу AuthGate замінить цей екран
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.auth;

    setState(() => _isLoading = true);
    try {
      // 2. перевірка облікових даних у firebase auth
      await auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final name = auth.currentUser?.vocativeName ?? '';
      messenger.showSnackBar(
        SnackBar(
          content: Text(name.isEmpty ? 'Вхід виконано' : 'Вітаємо, $name!'),
        ),
      );
      // переходити нікуди не треба: AuthGate сам покаже головний екран
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure.isWrongCredentials) _credentialsError = failure.message;
      });
      showAppSnackBar(context, failure.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              // Form обʼєднує поля, щоб перевірити їх одним validate()
              child: Form(
                key: _formKey,
                child: AutofillGroup(
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
                        autofillHints: const [AutofillHints.email],
                        enabled: !_isLoading,
                        validator: Validators.email,
                        // підсвічуємо і пошту, якщо дані входу неправильні
                        errorText: _credentialsError == null ? null : '',
                        onChanged: (_) => _clearServerError(),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      AppTextField(
                        label: 'Пароль',
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_isLoading,
                        validator: Validators.loginPassword,
                        errorText: _credentialsError,
                        onChanged: (_) => _clearServerError(),
                        onFieldSubmitted: (_) => _onLoginPressed(),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      PrimaryButton(
                        label: 'Увійти',
                        isLoading: _isLoading,
                        onPressed: _onLoginPressed,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          // pushNamed — кладемо екран ПОВЕРХ входу,
                          // «Назад» поверне сюди; передаємо введену пошту
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pushNamed(
                                    AppRoutes.forgotPassword,
                                    arguments: _emailController.text.trim(),
                                  ),
                          child: const Text('Забули пароль?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      const TextDivider(text: 'або'),
                      const SizedBox(height: AppSpacing.medium),
                      SecondaryButton(
                        label: 'Створити обліковий запис',
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context)
                                .pushNamed(AppRoutes.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// щойно користувач змінює дані, серверна помилка зникає
  void _clearServerError() {
    if (_credentialsError != null) setState(() => _credentialsError = null);
  }
}
