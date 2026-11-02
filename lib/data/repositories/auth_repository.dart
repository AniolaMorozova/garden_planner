import '../models/app_user.dart';

/// контракт роботи з автентифікацією
/// екрани знають лише про цей інтерфейс, а реалізація з firebase —
/// у FirebaseAuthRepository; для тестів можна підставити фейкову
abstract interface class AuthRepository {
  /// потік змін користувача: вхід, вихід, оновлення імені чи фото
  /// null означає, що користувач не увійшов
  Stream<AppUser?> userChanges();

  /// поточний користувач або null
  AppUser? get currentUser;

  /// реєстрація за імʼям, поштою та паролем (FR-01)
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// вхід за поштою та паролем (FR-02)
  Future<void> signIn({required String email, required String password});

  /// лист із посиланням для скидання пароля (FR-03)
  Future<void> sendPasswordResetEmail({required String email});

  /// зміна імені та/або посилання на фото профілю (FR-04, FR-11)
  Future<void> updateProfile({required String name, String? photoUrl});

  /// зміна пароля з перевіркою поточного (FR-04)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// вихід з облікового запису (FR-02)
  Future<void> signOut();
}
