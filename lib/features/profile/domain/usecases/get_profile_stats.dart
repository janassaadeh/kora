import 'package:kora/features/profile/data/repositories/profile_repository.dart';

class GetProfileStats {
  final ProfileRepository repository;

  GetProfileStats(this.repository);

  Future<({int streak, int entryCount, double? vitalityScore})> call() =>
      repository.getProfileStats();
}