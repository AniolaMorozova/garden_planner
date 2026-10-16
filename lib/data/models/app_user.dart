/// модель користувача (поки без бекенду — дані захардкоджено в mock
class AppUser {
  // const-конструктор, обʼєкт можна створити на етапі компіляції, Flutter не створює його заново при кожній перебудові
  const AppUser({
    required this.fullName,
    required this.vocativeName,
    required this.email,
    required this.plotsCount,
    required this.plantsCount,
    required this.tasksCount,
  });

  // final, поля не можна змінити після створення
  final String fullName;
  final String vocativeName;
  final String email;

  // статистика для профілю: «6 ділянок, 18 рослин, 42 роботи»
  final int plotsCount;
  final int plantsCount;
  final int tasksCount;

  /// геттер обчислюване поле, Анна Морозова стане АМ
  String get initials => fullName
      .trim()
      .split(RegExp(r'\s+')) // розбиваємо на слова
      .where((part) => part.isNotEmpty)
      .take(2) // беремо імʼя та прізвище
      .map((part) => part[0].toUpperCase()) // перша літера кожного
      .join();
}