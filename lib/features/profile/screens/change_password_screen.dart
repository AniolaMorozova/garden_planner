import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/requirement_check_row.dart';
import '../../../data/repositories/auth_failure.dart';

/// зміна пароля (FR-04)
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _repeatController = TextEditingController();

  bool _isLoading = false;
  String? _currentPasswordError; // «поточний пароль неправильний» від firebase

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  /// новий пароль: вимоги + не має збігатися з поточним
  String? _validateNewPassword(String? value) {
    final error = Validators.newPassword(value);
    if (error != null) return error;
    if (value == _currentController.text) {
      return 'Новий пароль має відрізнятися від поточного';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _currentPasswordError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.auth.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Пароль змінено');
      Navigator.of(context).pop(); // назад у профіль
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (failure.isWrongCredentials) {
        // повторна автентифікація не пройшла — поточний пароль хибний
        setState(() => _currentPasswordError = 'Поточний пароль неправильний');
        showAppSnackBar(context, 'Поточний пароль неправильний', isError: true);
      } else if (failure.requiresRecentLogin) {
        await _showReLoginDialog(failure.message);
      } else {
        showAppSnackBar(context, failure.message, isError: true);
      }
    }
  }

  /// firebase вимагає свіжого входу: пропонуємо вийти й увійти знову
  Future<void> _showReLoginDialog(String message) async {
    final auth = context.auth;
    final reLogin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_clock_outlined),
        title: const Text('Потрібен повторний вхід'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Увійти знову'),
          ),
        ],
      ),
    );
    if (reLogin ?? false) await auth.signOut(); // AuthGate покаже вхід
  }

  @override
  Widget build(BuildContext context) {
    final newPassword = _newController.text;

    return Scaffold(
      appBar: AppBar(title: const Text('Зміна пароля')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              AppTextField(
                label: 'Поточний пароль',
                controller: _currentController,
                isPassword: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                enabled: !_isLoading,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Введіть поточний пароль'
                    : null,
                errorText: _currentPasswordError,
                onChanged: (_) {
                  if (_currentPasswordError != null) {
                    setState(() => _currentPasswordError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.large),
              AppTextField(
                label: 'Новий пароль',
                controller: _newController,
                isPassword: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_isLoading,
                validator: _validateNewPassword,
                // порожній setState оновлює чек-лист вимог під полями
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.large),
              AppTextField(
                label: 'Повторіть новий пароль',
                controller: _repeatController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                validator: Validators.repeatPassword(_newController),
                onFieldSubmitted: (_) => _onSubmit(),
              ),
              const SizedBox(height: AppSpacing.medium),
              // підказки оновлюються під час введення
              RequirementCheckRow(
                label: 'Щонайменше 8 символів',
                isMet: Validators.hasMinLength(newPassword),
              ),
              const SizedBox(height: AppSpacing.small),
              RequirementCheckRow(
                label: 'Літери та цифри',
                isMet: Validators.hasLettersAndDigits(newPassword),
              ),
              const SizedBox(height: AppSpacing.xl + AppSpacing.small),
              PrimaryButton(
                label: 'Змінити пароль',
                isLoading: _isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
