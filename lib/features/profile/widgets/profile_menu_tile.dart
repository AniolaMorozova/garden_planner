import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// пункт меню профілю зі стрілкою праворуч
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // listtile сам розставляє іконку, текст і стрілку в рядок
    return ListTile(
      contentPadding: EdgeInsets.zero, // без зайвих відступів по краях
      minLeadingWidth: 24,
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}