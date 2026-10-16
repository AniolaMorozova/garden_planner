import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// поле введення застосунку: підпис у рамці, біле тло
/// для паролів має кнопку показу/приховування тексту
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.onChanged,
  });

  final String label; // підпис у рамці: «Електронна пошта»
  final TextEditingController? controller; // через нього екран читає введений текст
  final String? hintText; // сіра підказка в порожньому полі
  final String? helperText; // текст під полем: «Мінімум 8 символів...»
  final String? errorText; // червоний текст помилки під полем
  final TextInputType? keyboardType; // тип клавіатури (наприклад, з @ для пошти)
  final TextInputAction? textInputAction; // кнопка на клавіатурі: «далі» чи «готово»
  final bool isPassword;
  final bool enabled; // false — поле лише для перегляду
  final ValueChanged<String>? onChanged; // викликається при кожній зміні тексту

  // Flutter викликає цей метод, щоб створити обʼєкт стану
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // стан: чи приховано пароль зірочками, спочатку — так
  bool _obscured = true;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    // до параметрів StatefulWidget зі стану звертаємось через widget
    final hasError = widget.errorText != null;

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      //текст приховується, лише якщо це пароль І _obscured == true
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        // підпис завжди сидить на рамці, навіть коли поле порожнє
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // при помилці підпис стає червоним
        labelStyle: TextStyle(
          color: hasError ? AppColors.error : AppColors.labelGreen,
          fontWeight: FontWeight.w600,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        helperText: widget.helperText,
        helperStyle: const TextStyle(color: AppColors.textSecondary),
        errorText: widget.errorText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        // різні рамки для різних станів поля:
        border: _border(AppColors.fieldBorder),
        enabledBorder: _border(AppColors.textSecondary.withValues(alpha: 0.5)),
        disabledBorder: _border(AppColors.fieldBorder),
        focusedBorder: _border(AppColors.primary, 1.5), // курсор у полі
        errorBorder: _border(AppColors.error), // є помилка
        focusedErrorBorder: _border(AppColors.error, 1.5),
        // іконка ока — лише для паролів (інакше null, тобто нічого)
        suffixIcon: widget.isPassword
            ? IconButton(
          tooltip: _obscured ? 'Показати пароль' : 'Приховати пароль',
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          // змінюємо стан і просимо флатер перебудувати віджет
          onPressed: () => setState(() => _obscured = !_obscured),
        )
            : null,
      ),
    );
  }
}