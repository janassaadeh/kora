import 'dart:io';
import 'package:kora/features/auth/domain/entities/app_user.dart';
import 'package:kora/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:kora/features/profile/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> getProfile() => remoteDataSource.getProfile();

  @override
  Future<String> uploadProfilePhoto(File file) =>
      remoteDataSource.uploadProfilePhoto(file);

  @override
  Future<({int streak, int entryCount, double? vitalityScore})> getProfileStats() =>
      remoteDataSource.getProfileStats();
}