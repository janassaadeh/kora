import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/auth/domain/entities/app_user.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kora/features/profile/presentation/bloc/profile_event.dart';
import 'package:kora/features/profile/presentation/bloc/profile_state.dart';
import 'package:kora/features/profile/presentation/widgets/stat_card.dart';
import 'package:kora/core/common/list_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          'Profile',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
        ),
       
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: AppLoader());
          }

          if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final AppUser user;
          final int streak;
          final int entryCount;
          final bool isUploading;
          final double? vitalityScore;


          if (state is ProfileLoaded) {
            user = state.user;
            streak = state.streak;
            entryCount = state.entryCount;
            isUploading = false;
            vitalityScore= state.vitalityScore;
          } else if (state is ProfilePhotoUploading) {
            user = state.user;
            streak = state.streak;
            entryCount = state.entryCount;
            isUploading = true;
            vitalityScore= state.vitalityScore;
            
          } else {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 12),
                // const Text(
                //   'Profile',
                //   style: TextStyle(
                //     color: AppColors.primary,
                //     fontSize: 32,
                //     fontWeight: FontWeight.bold,
                //     letterSpacing: 0.2,
                //   ),
                // ),
                const SizedBox(height: 12),

                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: isUploading ? null : () => _pickPhoto(context),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 118,
                          height: 118,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                AppColors.accent.withOpacity(0.9),
                                AppColors.primary.withOpacity(0.9),
                                AppColors.accent.withOpacity(0.95),
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: _buildAvatar(user, isUploading),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isUploading
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: AppLoader(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Center(
                  child: Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : user.email,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Stats
                StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '$streak Day Streak',
                  label: 'CONSISTENCY',
                ),
                const SizedBox(height: 14),
                StatCard(
                  icon: Icons.menu_book_outlined,
                  value: '$entryCount Reflections',
                  label: 'ARCHIVE ENTRIES',
                ),
                const SizedBox(height: 14),
                StatCard(
                  icon: Icons.favorite_border,
                  value: vitalityScore != null
                      ? '${vitalityScore.toStringAsFixed(0)} Wellness Score'
                      : 'No Score Yet',
                  label: 'VITALITY',
                ),
                // const SizedBox(height: 14),

                // ListItem(
                //   iconWidget: Container(
                //     width: 48,
                //     height: 48,
                //     decoration: BoxDecoration(
                //       color: AppColors.accent.withOpacity(0.8),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(
                //       Icons.person_outline,
                //       color: AppColors.primary,
                //       size: 22,
                //     ),
                //   ),
                //   title: 'Library Archive',
                //   subtitle: 'View all your saved moments',
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const ProfileScreen()),
                //   ),
                // ),

                const SizedBox(height: 28),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignOutRequested());
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
  // Replace _buildAvatar in profile_screen.dart with this:

  Widget _buildAvatar(AppUser user, bool isUploading) {
    if (isUploading) {
      return const CircleAvatar(
        backgroundColor: Colors.transparent,
        child: AppLoader(strokeWidth: 2),
      );
    }

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      // base64 string → show as memory image
      try {
        final bytes = base64Decode(user.photoUrl!);
        return CircleAvatar(
          backgroundImage: MemoryImage(bytes),
          backgroundColor: Colors.transparent,
        );
      } catch (_) {
        // fallback if somehow it's a URL
        return CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl!),
          backgroundColor: Colors.transparent,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.95),
            AppColors.primary.withOpacity(0.9),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    if (!context.mounted) return;
    context.read<ProfileBloc>().add(
      UploadProfilePhotoRequested(File(picked.path)),
    );
  }
}
