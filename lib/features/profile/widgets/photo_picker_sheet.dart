import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

/// результат вибору фото: null — скасовано, '' — видалити фото,
/// інакше — https-посилання на нове фото
const String removePhotoResult = '';

/// набір готових зображень із фіксованими https-посиланнями
/// (завантаження власних файлів у storage буде в лабораторній №6)
const List<String> presetPhotoUrls = [
  'https://picsum.photos/id/1080/300/300',
  'https://picsum.photos/id/106/300/300',
  'https://picsum.photos/id/152/300/300',
  'https://picsum.photos/id/292/300/300',
  'https://picsum.photos/id/429/300/300',
  'https://picsum.photos/id/1043/300/300',
];

/// відкриває нижню панель вибору фото профілю
Future<String?> showPhotoPickerSheet(
  BuildContext context, {
  String? currentUrl,
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // панель піднімається над клавіатурою
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (_) => PhotoPickerSheet(currentUrl: currentUrl),
    );

class PhotoPickerSheet extends StatefulWidget {
  const PhotoPickerSheet({super.key, this.currentUrl});

  final String? currentUrl;

  @override
  State<PhotoPickerSheet> createState() => _PhotoPickerSheetState();
}

class _PhotoPickerSheetState extends State<PhotoPickerSheet> {
  final _urlFormKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  String? _selectedUrl; // що зараз вибрано (показуємо в попередньому перегляді)
  bool _isCheckingUrl = false;
  String? _urlLoadError; // посилання правильне, але зображення не завантажилось

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// перевіряє власне посилання: формат https і що зображення справді
  /// завантажується, і лише тоді показує його в попередньому перегляді
  Future<void> _previewCustomUrl() async {
    FocusScope.of(context).unfocus();
    setState(() => _urlLoadError = null);
    if (!_urlFormKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    setState(() => _isCheckingUrl = true);
    var failed = false;
    await precacheImage(
      NetworkImage(url),
      context,
      onError: (_, _) => failed = true,
    );
    if (!mounted) return;
    setState(() {
      _isCheckingUrl = false;
      if (failed) {
        _urlLoadError = 'Не вдалося завантажити зображення за посиланням';
      } else {
        _selectedUrl = url;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedUrl != null && _selectedUrl!.isNotEmpty;

    return Padding(
      // відступ знизу дорівнює висоті клавіатури
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.large,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Фото профілю',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            // попередній перегляд вибраного фото
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.accentLight,
                foregroundImage:
                    hasSelection ? NetworkImage(_selectedUrl!) : null,
                onForegroundImageError: hasSelection ? (_, _) {} : null,
                child: const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            const Text(
              'Оберіть зображення',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.normal),
            // сітка готових зображень
            Wrap(
              spacing: AppSpacing.normal,
              runSpacing: AppSpacing.normal,
              alignment: WrapAlignment.center,
              children: [
                for (final url in presetPhotoUrls)
                  _PresetPhoto(
                    url: url,
                    isSelected: url == _selectedUrl,
                    onTap: () => setState(() {
                      _selectedUrl = url;
                      _urlLoadError = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            const Text(
              'Або вставте власне посилання',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.normal),
            Form(
              key: _urlFormKey,
              child: AppTextField(
                label: 'Посилання на зображення',
                controller: _urlController,
                hintText: 'https://...',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: Validators.httpsImageUrl,
                errorText: _urlLoadError,
                onChanged: (_) {
                  if (_urlLoadError != null) {
                    setState(() => _urlLoadError = null);
                  }
                },
                onFieldSubmitted: (_) => _previewCustomUrl(),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isCheckingUrl ? null : _previewCustomUrl,
                icon: _isCheckingUrl
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.visibility_outlined),
                label: const Text('Переглянути'),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            PrimaryButton(
              label: 'Застосувати',
              // кнопка активна, лише якщо вибір змінився
              onPressed: hasSelection && _selectedUrl != widget.currentUrl
                  ? () => Navigator.of(context).pop(_selectedUrl)
                  : null,
            ),
            if (widget.currentUrl != null && widget.currentUrl!.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.of(context).pop(removePhotoResult),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Видалити фото'),
              ),
          ],
        ),
      ),
    );
  }
}

/// кругле готове зображення з зеленою рамкою, якщо вибране
class _PresetPhoto extends StatelessWidget {
  const _PresetPhoto({
    required this.url,
    required this.isSelected,
    required this.onTap,
  });

  final String url;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Готове фото',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceMuted,
            foregroundImage: NetworkImage(url),
            onForegroundImageError: (_, _) {},
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
