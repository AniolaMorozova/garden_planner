import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/feature_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_failure.dart';
import '../widgets/photo_picker_sheet.dart';

/// редагування профілю: імʼя та фото (FR-04, FR-11)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // late бо значення присвоюємо в initstate
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final AppUser? _user;

  String? _photoUrl; // вибране фото (ще не збережене)
  bool _isSaving = false;

  // initstate викликається один раз, тут заповнюємо поля поточними даними
  @override
  void initState() {
    super.initState();
    _user = context.auth.currentUser;
    _nameController = TextEditingController(text: _user?.fullName ?? '');
    _emailController = TextEditingController(text: _user?.email ?? '');
    _photoUrl = _user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _nameController.text.trim() != (_user?.fullName ?? '') ||
      _photoUrl != _user?.photoUrl;

  Future<void> _pickPhoto() async {
    final result = await showPhotoPickerSheet(context, currentUrl: _photoUrl);
    if (result == null) return; // панель закрили без вибору
    setState(() => _photoUrl = result == removePhotoResult ? null : result);
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.auth.updateProfile(
        name: _nameController.text,
        photoUrl: _photoUrl,
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Зміни збережено');
      Navigator.of(context).pop();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      showAppSnackBar(context, failure.message, isError: true);
      setState(() => _isSaving = false);
    }
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
            onPressed: _isSaving ? null : _onSave,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Center(
                child: UserAvatar(
                  initials: _user?.initials ?? '?',
                  photoUrl: _photoUrl,
                  radius: 52,
                  onCameraTap: _isSaving ? null : _pickPhoto,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _isSaving ? null : _pickPhoto,
                  child: const Text('Змінити фото'),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              AppTextField(
                label: 'Імʼя та прізвище',
                controller: _nameController,
                textInputAction: TextInputAction.done,
                maxLength: Validators.maxNameLength,
                enabled: !_isSaving,
                validator: Validators.name,
                onFieldSubmitted: (_) => _onSave(),
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
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.normal),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Зберегти',
                      isLoading: _isSaving,
                      onPressed: _onSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
