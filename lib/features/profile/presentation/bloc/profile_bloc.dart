import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/profile/domain/usecases/get_profile.dart';
import 'package:kora/features/profile/domain/usecases/get_profile_stats.dart';
import 'package:kora/features/profile/domain/usecases/upload_profile.dart';
import 'package:kora/features/profile/presentation/bloc/profile_event.dart';
import 'package:kora/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final GetProfileStats getProfileStats;
  final UploadProfilePhoto uploadProfilePhoto;

  ProfileBloc({
    required this.getProfile,
    required this.getProfileStats,
    required this.uploadProfilePhoto,
  }) : super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<UploadProfilePhotoRequested>(_onUploadPhoto);
  }
Future<void> _onLoadProfile(
  LoadProfileRequested event,
  Emitter<ProfileState> emit,
) async {
  if (state is ProfileLoaded) return;

  emit(ProfileLoading());
  try {
    final user = await getProfile();
    final stats = await getProfileStats();
    emit(ProfileLoaded(
      user: user,
      streak: stats.streak,
      entryCount: stats.entryCount,
      vitalityScore: stats.vitalityScore,
    ));
  } catch (e) {
    emit(ProfileError(e.toString()));
  }
}
  Future<void> _onUploadPhoto(
    UploadProfilePhotoRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(ProfilePhotoUploading(
      user: current.user,
      streak: current.streak,
      entryCount: current.entryCount,
      vitalityScore: current.vitalityScore,
    ));

    try {
      await uploadProfilePhoto(event.file);
      final user = await getProfile();
      emit(current.copyWith(user: user));
    } catch (e) {
      emit(current);
    }
  }
}