import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/uk_format.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/task_tile.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/garden_task.dart';
import '../widgets/day_summary_card.dart';
import '../widgets/quick_action_button.dart';

/// головний екран
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // копія захардкодженого списку: його можна змінювати
  final List<GardenTask> _tasks = List.of(MockData.todayTasks);

  // геттер: кількість виконаних обчислюється щоразу з актуального списку
  int get _doneCount => _tasks.where((task) => task.isDone).length;

  // викликається, коли користувач ставить/знімає галочку на картці
  void _toggleTask(int index, bool isDone) {
    setState(() => _tasks[index] = _tasks[index].copyWith(isDone: isDone));
  }

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;
    final textTheme = Theme.of(context).textTheme;
    final sectionTitle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      // FAB — кругла кнопка «+» у правому нижньому куті
      floatingActionButton: FloatingActionButton(
        tooltip: 'Нова робота',
        onPressed: () => showNotImplemented(context, 'Нова робота'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        // ListView — прокручуваний список: якщо робіт багато, екран гортається
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.normal,
            AppSpacing.medium,
            96, // знизу місце, щоб FAB не закривав останню картку
          ),
          children: [
            // привітання, дата й аватар
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Привіт, ${user.vocativeName}!',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        // сьогоднішня дата
                        UkFormat.weekdayDayMonth(DateTime.now()),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                UserAvatar(
                  initials: user.initials,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.profile),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            DaySummaryCard(total: _tasks.length, done: _doneCount),
            const SizedBox(height: AppSpacing.large),
            Text('Швидкі дії', style: sectionTitle),
            const SizedBox(height: AppSpacing.normal),
            Row(
              children: [
                // Expanded — три кнопки ділять ширину порівну.
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.calendar_today_outlined,
                    label: 'Робота',
                    onTap: () => showNotImplemented(context, 'Нова робота'),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.eco_outlined,
                    label: 'Рослина',
                    onTap: () => showNotImplemented(context, 'Нова рослина'),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.grid_on_outlined,
                    label: 'Ділянка',
                    onTap: () => showNotImplemented(context, 'Нова ділянка'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Роботи на сьогодні', style: sectionTitle),
                TextButton(
                  onPressed: () => showNotImplemented(context, 'Календар робіт'),
                  child: const Text('Усі'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // collection-for: картка TaskTile для кожної роботи зі списку.
            for (var i = 0; i < _tasks.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.normal),
                child: TaskTile(
                  task: _tasks[i],
                  onToggle: (isDone) => _toggleTask(i, isDone),
                  onTap: () =>
                      showNotImplemented(context, 'Редагування роботи'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}