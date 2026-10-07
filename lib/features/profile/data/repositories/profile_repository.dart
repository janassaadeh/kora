import 'dart:io';
import 'package:kora/features/auth/domain/entities/app_user.dart';

abstract class ProfileRepository {
  Future<AppUser> getProfile();
  Future<String> uploadProfilePhoto(File file);
  Future<({int streak, int entryCount, double? vitalityScore})> getProfileStats();
}