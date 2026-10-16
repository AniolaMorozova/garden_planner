import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/mock/mock_data.dart';

/// екран відновлення пароля через електронну пошту
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// без бекенду: лише показуємо підтвердження надсилання листа
  void _onSendPressed() {
    final typed = _emailController.text.trim(); // trim() прибирає пробіли
    final email = typed.isEmpty ? MockData.user.email : typed;
    showAppSnackBar(context, 'Лист надіслано на $email');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Відновлення пароля')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    'Забули пароль?',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                  Text(
                    'Вкажіть адресу пошти, з якою Ви реєструвались. '
                        'Ми надішлемо посилання для встановлення нового пароля.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Електронна пошта',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  PrimaryButton(
                    label: 'Надіслати посилання',
                    onPressed: _onSendPressed,
                  ),
                  const SizedBox(height: AppSpacing.normal),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Повернутись до входу'),
                    ),
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