import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.signIn(
      email: email,
      password: password,
    );
    final user = result.user!;
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,

  }) async {
    final result = await remoteDataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,

    );
    final user = result.user!;
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<AppUser> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  // Add this
  @override
  Future<AppUser> signInWithGoogle() async {
    final result = await remoteDataSource.signInWithGoogle();
    final user = result.user!;
    return AppUser(uid: user.uid, email: user.email ?? '');
  }
}