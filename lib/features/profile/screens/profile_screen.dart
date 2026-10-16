import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/uk_format.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/mock/mock_data.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stats_card.dart';

/// профіль користувача
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // без бекенду просто повертаємось на вхід і чистимо весь стек екранів
  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const user = MockData.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          // меню з трьома крапками
          PopupMenuButton<String>(
            tooltip: 'Більше',
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).pushNamed(AppRoutes.editProfile);
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Редагувати профіль')),
              PopupMenuItem(value: 'logout', child: Text('Вийти')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.large,
          ),
          children: [
            // великий аватар з кнопкою камери
            Center(
              child: UserAvatar(
                initials: user.initials,
                radius: 60,
                onCameraTap: () => showNotImplemented(context, 'Зміна фото'),
              ),
            ),
            const SizedBox(height: AppSpacing.normal),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.large),
            // підписи відмінюються: 6 ділянок, 18 рослин, 42 роботи
            ProfileStatsCard(
              stats: [
                ProfileStat(
                  value: user.plotsCount,
                  label: UkFormat.plural(
                      user.plotsCount, 'ділянка', 'ділянки', 'ділянок'),
                ),
                ProfileStat(
                  value: user.plantsCount,
                  label: UkFormat.plural(
                      user.plantsCount, 'рослина', 'рослини', 'рослин'),
                ),
                ProfileStat(
                  value: user.tasksCount,
                  label: UkFormat.plural(
                      user.tasksCount, 'робота', 'роботи', 'робіт'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ProfileMenuTile(
              icon: Icons.edit_outlined,
              title: 'Редагувати профіль',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
            ),
            const Divider(height: 1),
            ProfileMenuTile(
              icon: Icons.lock_outline,
              title: 'Змінити пароль',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.changePassword),
            ),
            const Divider(height: 1),
            ProfileMenuTile(
              icon: Icons.notifications_none,
              title: 'Сповіщення',
              onTap: () => showNotImplemented(context, 'Сповіщення'),
            ),
            const SizedBox(height: AppSpacing.xl + AppSpacing.small),
            // червоний текст, сіра рамка, як на макеті
            SecondaryButton(
              label: 'Вийти з облікового запису',
              foregroundColor: AppColors.error,
              borderColor: AppColors.textSecondary,
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}