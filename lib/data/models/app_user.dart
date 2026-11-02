import '../../core/utils/uk_format.dart';

/// модель користувача застосунку
/// дані профілю (uid, імʼя, пошта, фото) беруться з firebase auth,
/// а статистика поки заглушка — реальні дані будуть з cloud firestore
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.createdAt,
    this.plotsCount = 0,
    this.plantsCount = 0,
    this.tasksCount = 0,
  });

  final String uid; // унікальний ідентифікатор з firebase auth
  final String fullName;
  final String email;
  final String? photoUrl; // https-посилання на фото профілю (може не бути)
  final DateTime? createdAt; // дата реєстрації

  // статистика для профілю: «6 ділянок, 18 рослин, 42 роботи»
  final int plotsCount;
  final int plantsCount;
  final int tasksCount;

  /// перше слово з імені: «Анна Морозова» -> «Анна»
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  /// кличний відмінок для привітання: «Анна» -> «Анно»
  String get vocativeName => UkFormat.vocative(firstName);

  /// геттер обчислюване поле, Анна Морозова стане АМ
  /// якщо імені немає — перша літера пошти
  String get initials {
    final letters = fullName
        .trim()
        .split(RegExp(r'\s+')) // розбиваємо на слова
        .where((part) => part.isNotEmpty)
        .take(2) // беремо імʼя та прізвище
        .map((part) => part[0].toUpperCase()) // перша літера кожного
        .join();
    if (letters.isNotEmpty) return letters;
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }
}
