import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// круглий аватар користувача: фото за посиланням або ініціали
/// якщо передано [onCameraTap] — показує значок камери для зміни фото
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.radius = 20,
    this.onTap,
    this.onCameraTap,
  });

  final String initials; // «АМ»
  final String? photoUrl; // https-посилання на фото профілю
  final double radius; // 20 — у верхній панелі, 60 — у профілі
  final VoidCallback? onTap; // натискання на сам аватар
  final VoidCallback? onCameraTap; // натискання на значок камери

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.accentLight,
      // фото малюється поверх ініціалів; якщо не завантажилось (немає мережі,
      // бите посилання) — лишаються видимими ініціали
      foregroundImage: (photoUrl == null || photoUrl!.isEmpty)
          ? null
          : NetworkImage(photoUrl!),
      onForegroundImageError: (photoUrl == null || photoUrl!.isEmpty)
          ? null
          : (_, _) {},
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: radius * 0.7, // розмір літер залежить від розміру аватара
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    // Stack: значок камери накладається поверх кола.
    if (onCameraTap != null) {
      avatar = Stack(
        clipBehavior: Clip.none, // значок може трохи виходити за межі
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primary,
              // Біла обводка відділяє значок від аватара.
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.background, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(), // хвиля натискання по колу
                onTap: onCameraTap,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return avatar;

    // Semantics — підказка для екранного читача (доступність)
    return Semantics(
      button: true,
      label: 'Профіль',
      child: GestureDetector(onTap: onTap, child: avatar),
    );
  }
}