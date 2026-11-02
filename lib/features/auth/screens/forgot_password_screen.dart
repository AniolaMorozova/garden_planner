import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/repositories/auth_failure.dart';

/// екран відновлення пароля через електронну пошту (FR-03)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _sentToEmail; // не null — лист надіслано, показуємо підтвердження

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // пошта, яку користувач уже ввів на екрані входу (аргумент маршруту)
    final email = ModalRoute.of(context)?.settings.arguments;
    if (email is String && _emailController.text.isEmpty) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await context.auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _sentToEmail = email);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      showAppSnackBar(context, failure.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSent = _sentToEmail != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Відновлення пароля')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
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
                        child: Icon(
                          isSent ? Icons.mark_email_read_outlined : Icons.mail_outline,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      isSent ? 'Перевірте пошту' : 'Забули пароль?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.normal),
                    Text(
                      // firebase не повідомляє, чи існує акаунт (захист від
                      // перебору адрес), тому формулюємо обережно
                      isSent
                          ? 'Якщо обліковий запис з адресою $_sentToEmail існує, '
                              'ми надіслали на неї лист із посиланням для '
                              'встановлення нового пароля. Перевірте також «Спам».'
                          : 'Вкажіть адресу пошти, з якою Ви реєструвались. '
                              'Ми надішлемо посилання для встановлення нового пароля.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!isSent) ...[
                      AppTextField(
                        label: 'Електронна пошта',
                        controller: _emailController,
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        validator: Validators.email,
                        onFieldSubmitted: (_) => _onSendPressed(),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      PrimaryButton(
                        label: 'Надіслати посилання',
                        isLoading: _isLoading,
                        onPressed: _onSendPressed,
                      ),
                    ] else
                      PrimaryButton(
                        label: 'Повернутись до входу',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    const SizedBox(height: AppSpacing.normal),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : isSent
                                // ще раз показуємо форму, щоб змінити пошту
                                ? () => setState(() => _sentToEmail = null)
                                : () => Navigator.of(context).pop(),
                        child: Text(
                          isSent ? 'Надіслати ще раз' : 'Повернутись до входу',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
