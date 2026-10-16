import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/uk_format.dart';

/// Темно-зелена картка з підсумком дня та круговим індикатором прогресу.
class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({super.key, required this.total, required this.done});

  final int total; // скільки робіт на сьогодні
  final int done; // скільки з них виконано

  @override
  Widget build(BuildContext context) {
    // Частка виконаних від 0.0 до 1.0 (захист від ділення на нуль).
    final progress = total == 0 ? 0.0 : done / total;
    // «4 роботи», «5 робіт» — функція з кроку 4.
    final word = UkFormat.plural(total, 'робота', 'роботи', 'робіт');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.banner),
      ),
      child: Row(
        children: [
          // Ліва частина: тексти.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сьогодні заплановано:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total $word',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Виконано: $done з $total',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Права частина: кільце прогресу з відсотком усередині.
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: AppColors.accentLight, // заповнена частина
                  backgroundColor: Colors.white, // «доріжка»
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}