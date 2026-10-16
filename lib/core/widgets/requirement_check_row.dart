import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// рядок чек-листа вимог (наприклад, до пароля)
class RequirementCheckRow extends StatelessWidget {
  const RequirementCheckRow({
    super.key,
    required this.label,
    required this.isMet,
  });

  final String label; // «Щонайменше 8 символів»
  final bool isMet; // чи виконана вимога

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          // тернарний оператор:
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isMet ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}