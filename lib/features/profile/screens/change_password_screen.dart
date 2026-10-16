import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/requirement_check_row.dart';

/// зміна пароля, перевірки поки тільки на рівні інтерфейсу
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _repeatController = TextEditingController();

  // шаблони: будь-яка літера (латиниця або кирилиця) і будь-яка цифра
  static final _letterRegExp = RegExp(r'[A-Za-zА-Яа-яЇїІіЄєҐґ]');
  static final _digitRegExp = RegExp(r'\d');

  // геттери перераховуються при кожному build
  bool get _hasMinLength => _newController.text.length >= 8;

  bool get _hasLettersAndDigits =>
      _letterRegExp.hasMatch(_newController.text) &&
          _digitRegExp.hasMatch(_newController.text);

  // помилку показуємо тільки якщо в повторі вже щось введено
  bool get _passwordsMismatch =>
      _repeatController.text.isNotEmpty &&
          _repeatController.text != _newController.text;

  bool get _canSubmit =>
      _currentController.text.isNotEmpty &&
          _hasMinLength &&
          _hasLettersAndDigits &&
          _repeatController.text == _newController.text;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_canSubmit) {
      showAppSnackBar(context, 'Перевірте введені паролі');
      return;
    }
    // справжня зміна пароля буде через firebase auth
    showAppSnackBar(context, 'Пароль змінено');
    Navigator.of(context).pop(); // назад у профіль
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Зміна пароля')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            AppTextField(
              label: 'Поточний пароль',
              controller: _currentController,
              isPassword: true,
              textInputAction: TextInputAction.next,
              // порожній setState просто перебудовує екран з новим текстом
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.large),
            AppTextField(
              label: 'Новий пароль',
              controller: _newController,
              isPassword: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.large),
            AppTextField(
              label: 'Повторіть новий пароль',
              controller: _repeatController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              // якщо errortext не null, поле стає червоним
              errorText: _passwordsMismatch ? 'Паролі не збігаються' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.medium),
            RequirementCheckRow(
              label: 'Щонайменше 8 символів',
              isMet: _hasMinLength,
            ),
            const SizedBox(height: AppSpacing.small),
            RequirementCheckRow(
              label: 'Літери та цифри',
              isMet: _hasLettersAndDigits,
            ),
            const SizedBox(height: AppSpacing.xl + AppSpacing.small),
            PrimaryButton(
              label: 'Змінити пароль',
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}