import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> forgotPassword(String email);

  Future<void> signOut();
  Future<AppUser> getCurrentUser();

  // Add this
  Future<AppUser> signInWithGoogle();
  
}