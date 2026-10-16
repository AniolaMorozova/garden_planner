import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';

/// екран реєстрації
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  // обробник натискання на частину тексту «умовами використання»
  // late — значення присвоїмо пізніше, в initState()
  late final TapGestureRecognizer _termsRecognizer;

  // стан: чи поставлено галочку згоди з умовами
  bool _agreedToTerms = false;

  // initState() викликається один раз, коли екран створюється
  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => showNotImplemented(context, 'Умови використання');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  /// без бекенду: одразу відкриваємо головний екран і очищаємо стек, щоб «Назад» не повертав на реєстрацію чи вхід
  void _onRegisterPressed() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
          (route) => false, // false = видалити всі попередні маршрути
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // стрілка «назад» зʼявляється автоматично
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.large,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Створіть обліковий запис',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Імʼя та прізвище',
                    controller: _nameController,
                    hintText: 'Анна Морозова',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppTextField(
                    label: 'Електронна пошта',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    helperText: 'Мінімум 8 символів, літери та цифри',
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                  AppTextField(
                    label: 'Повторіть пароль',
                    controller: _repeatController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        // Ставимо/знімаємо галочку і перебудовуємо екран.
                        onChanged: (value) =>
                            setState(() => _agreedToTerms = value ?? false),
                      ),
                      Expanded(
                        // Text.rich: один рядок, різні стилі частин.
                        child: Text.rich(
                          TextSpan(
                            text: 'Погоджуюсь з ',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'умовами використання',
                                recognizer: _termsRecognizer, // клікабельна частина
                                style: const TextStyle(
                                  color: AppColors.link,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.link,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  PrimaryButton(
                    label: 'Зареєструватися',
                    // null → кнопка неактивна, поки немає згоди з умовами.
                    onPressed: _agreedToTerms ? _onRegisterPressed : null,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Уже є акаунт?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        // pop() — знімаємо цей екран зі стеку, повертаємось на вхід.
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Увійти'),
                      ),
                    ],
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