import 'dart:io';

abstract class ProfileEvent {}

class LoadProfileRequested extends ProfileEvent {}

class UploadProfilePhotoRequested extends ProfileEvent {
  final File file;
  UploadProfilePhotoRequested(this.file);
}