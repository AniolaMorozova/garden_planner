import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/uk_format.dart';
import '../../../core/widgets/current_user_builder.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/repositories/auth_failure.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stats_card.dart';

/// профіль користувача (FR-02, FR-04)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _logout() async {
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.auth;
    setState(() => _isSigningOut = true);
    try {
      await auth.signOut();
      // AuthGate закриє профіль і покаже екран входу
      messenger.showSnackBar(
        const SnackBar(content: Text('Ви вийшли з облікового запису')),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      showAppSnackBar(context, failure.message, isError: true);
      setState(() => _isSigningOut = false);
    }
  }

  /// діалог для перевірки firebase crashlytics (завдання 2)
  Future<void> _showCrashlyticsTest() async {
    final crash = context.crash;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тест Crashlytics'),
        content: const Text(
          'Нефатальна помилка реєструється одразу, застосунок працює далі.\n\n'
          'Фатальний збій аварійно закриє застосунок, звіт надійде після '
          'наступного запуску.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('crash'),
            child: const Text('Фатальний збій'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('non-fatal'),
            child: const Text('Нефатальна помилка'),
          ),
        ],
      ),
    );
    if (choice == 'non-fatal') {
      await crash.sendTestNonFatal();
      if (!mounted) return;
      showAppSnackBar(context, 'Тестову помилку надіслано в Crashlytics');
    } else if (choice == 'crash') {
      crash.testCrash();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          // меню з трьома крапками
          PopupMenuButton<String>(
            tooltip: 'Більше',
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).pushNamed(AppRoutes.editProfile);
                case 'crashlytics':
                  _showCrashlyticsTest();
                case 'logout':
                  _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Редагувати профіль')),
              PopupMenuItem(
                value: 'crashlytics',
                child: Text('Тест Crashlytics'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Вийти')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        // дані користувача з firebase auth, оновлюються після редагування
        child: CurrentUserBuilder(
          builder: (context, user) => ListView(
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
                  photoUrl: user.photoUrl,
                  radius: 60,
                  onCameraTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.editProfile),
                ),
              ),
              const SizedBox(height: AppSpacing.normal),
              Text(
                user.fullName.isEmpty ? 'Без імені' : user.fullName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (user.createdAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'З нами з ${UkFormat.dayMonthYear(user.createdAt!.toLocal())}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.large),
              // заглушка: реальна статистика буде з cloud firestore
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
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.editProfile),
              ),
              const Divider(height: 1),
              ProfileMenuTile(
                icon: Icons.lock_outline,
                title: 'Змінити пароль',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.changePassword),
              ),
              const Divider(height: 1),
              // заглушка: сповіщення будуть в окремій лабораторній
              ProfileMenuTile(
                icon: Icons.notifications_none,
                title: 'Сповіщення',
                onTap: () => showNotImplemented(context, 'Сповіщення'),
              ),
              const SizedBox(height: AppSpacing.xl + AppSpacing.small),
              // червоний текст, сіра рамка, як на макеті
              SecondaryButton(
                label: _isSigningOut
                    ? 'Виходимо...'
                    : 'Вийти з облікового запису',
                foregroundColor: AppColors.error,
                borderColor: AppColors.textSecondary,
                onPressed: _isSigningOut ? null : _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
