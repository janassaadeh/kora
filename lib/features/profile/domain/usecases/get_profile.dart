import 'package:kora/features/auth/domain/entities/app_user.dart';
import 'package:kora/features/profile/data/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<AppUser> call() => repository.getProfile();
}