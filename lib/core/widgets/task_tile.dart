import 'package:flutter/material.dart';

import '../../data/models/garden_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// картка садової роботи з чекбоксом виконання
/// використовується на головному екрані, згодом — у календарі
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
  });

  final GardenTask task;

  /// колбек: картка повідомляє «користувач змінив галочку на true/false»
  final ValueChanged<bool> onToggle;

  /// натискання на саму картку (згодом відкриватиме форму редагування)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;

    // Material + InkWell — щоб при натисканні була «хвиля» в межах картки.
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.small,
            vertical: AppSpacing.normal,
          ),
          child: Row(
            children: [
              Checkbox(
                value: done,
                // Checkbox повертає bool? (може бути null), тому ?? false.
                onChanged: (value) => onToggle(value ?? false),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Expanded — текст займає все місце, що лишилося праворуч.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        color: done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        // Виконана робота — закреслена, як на макеті.
                        decoration: done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${task.plotName} (${task.timeLabel})', // «Теплиця (7:00)»
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}