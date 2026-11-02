import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/repositories/auth_failure.dart';

/// екран реєстрації (FR-01)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // GlobalKey дає доступ до стану форми: validate() перевіряє всі поля
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  // обробник натискання на частину тексту «умовами використання»
  // late — значення присвоїмо пізніше, в initState()
  late final TapGestureRecognizer _termsRecognizer;

  bool _agreedToTerms = false; // чи поставлено галочку згоди з умовами
  bool _isLoading = false; // йде запит до firebase
  String? _emailServerError; // «пошта вже використана» під полем пошти

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

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    setState(() => _emailServerError = null);

    // локальна валідація всіх полів форми
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(context, 'Виправте помилки у формі', isError: true);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final auth = context.auth;

    setState(() => _isLoading = true); // блокуємо повторне надсилання
    try {
      await auth.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthGate сам закриє цей екран і покаже головний
      messenger.showSnackBar(
        const SnackBar(content: Text('Обліковий запис створено. Ласкаво просимо!')),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      // помилку пошти показуємо біля поля, решту — у snackbar
      setState(() {
        if (failure.isEmailError) _emailServerError = failure.message;
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
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Створіть обліковий запис',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // імʼя: обовʼязкове, 2–50 символів, лише літери
                      AppTextField(
                        label: 'Імʼя та прізвище',
                        controller: _nameController,
                        hintText: 'Анна Морозова',
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        maxLength: Validators.maxNameLength,
                        enabled: !_isLoading,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      // пошта: обовʼязкова і правильного формату
                      AppTextField(
                        label: 'Електронна пошта',
                        controller: _emailController,
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: !_isLoading,
                        validator: Validators.email,
                        errorText: _emailServerError,
                        onChanged: (_) {
                          if (_emailServerError != null) {
                            setState(() => _emailServerError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.large),
                      // пароль: мінімум 8 символів, літери та цифри
                      AppTextField(
                        label: 'Пароль',
                        controller: _passwordController,
                        helperText: 'Мінімум 8 символів, літери та цифри',
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !_isLoading,
                        validator: Validators.newPassword,
                      ),
                      const SizedBox(height: AppSpacing.normal),
                      // повтор має збігатися з паролем
                      AppTextField(
                        label: 'Повторіть пароль',
                        controller: _repeatController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        validator:
                            Validators.repeatPassword(_passwordController),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            // Ставимо/знімаємо галочку і перебудовуємо екран.
                            onChanged: _isLoading
                                ? null
                                : (value) => setState(
                                      () => _agreedToTerms = value ?? false,
                                    ),
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
                                    recognizer: _termsRecognizer,
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
                        isLoading: _isLoading,
                        // null → кнопка неактивна, поки немає згоди з умовами
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
                            // pop() — повертаємось на вхід
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
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
        ),
      ),
    );
  }
}
