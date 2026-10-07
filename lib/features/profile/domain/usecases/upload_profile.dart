import 'dart:io';

import 'package:kora/features/profile/data/repositories/profile_repository.dart';

class UploadProfilePhoto {
  final ProfileRepository repository;

  UploadProfilePhoto(this.repository);

  Future<String> call(File file) => repository.uploadProfilePhoto(file);
}