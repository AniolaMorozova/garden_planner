import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/current_user_builder.dart';
import '../../core/widgets/user_avatar.dart';

/// тимчасовий екран для розділів, які будуть реалізовані пізніше
class SectionPlaceholderScreen extends StatelessWidget {
  const SectionPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ці екрани відкриваються вкладками, а не через push, тому стрілки
        // «назад» тут не буде — як і на макетах
        title: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.medium),
            child: CurrentUserBuilder(
              builder: (context, user) => UserAvatar(
                initials: user.initials,
                photoUrl: user.photoUrl,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min, // колонка за висотою вмісту
            children: [
              Icon(icon, size: 56, color: AppColors.border),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Розділ «$title» зʼявиться в наступній версії застосунку',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}