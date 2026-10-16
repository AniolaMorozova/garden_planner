import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/mock/mock_data.dart';

/// редагування профілю: імʼя та фото
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // late бо значення присвоюємо в initstate
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  // initstate викликається один раз, тут заповнюємо поля поточними даними
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: MockData.user.fullName);
    _emailController = TextEditingController(text: MockData.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    // збереження у firestore додам разом з бекендом
    showAppSnackBar(context, 'Зміни збережено');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагування профілю'),
        actions: [
          // галочка зберегти, як на макетах форм з лаб 2
          IconButton(
            tooltip: 'Зберегти',
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _onSave,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            Center(
              child: UserAvatar(
                initials: MockData.user.initials,
                radius: 52,
                onCameraTap: () => showNotImplemented(context, 'Зміна фото'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Імʼя та прізвище',
              controller: _nameController,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.large),
            // пошту змінювати не можна, тільки показуємо
            AppTextField(
              label: 'Електронна пошта',
              controller: _emailController,
              enabled: false,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Скасувати',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.normal),
                Expanded(
                  child: PrimaryButton(
                    label: 'Зберегти',
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}