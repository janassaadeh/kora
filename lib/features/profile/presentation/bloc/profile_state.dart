import 'package:kora/features/auth/domain/entities/app_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AppUser user;
  final int streak;
  final int entryCount;
  final double? vitalityScore;

  ProfileLoaded({
    required this.user,
    required this.streak,
    required this.entryCount,
    this.vitalityScore,
  });

  ProfileLoaded copyWith({
    AppUser? user,
    int? streak,
    int? entryCount,
    double? vitalityScore,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      streak: streak ?? this.streak,
      entryCount: entryCount ?? this.entryCount,
      vitalityScore: vitalityScore ?? this.vitalityScore,
    );
  }
}

class ProfilePhotoUploading extends ProfileState {
  final AppUser user;
  final int streak;
  final int entryCount;
  final double? vitalityScore;

  ProfilePhotoUploading({
    required this.user,
    required this.streak,
    required this.entryCount,
    this.vitalityScore,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}