import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/profile/presentation/screens/profile_screen.dart';

import 'package:kora/core/common/list_item.dart';
import 'package:kora/features/settings/presentation/widgets/notification_list_item.dart';
import 'package:kora/features/settings/presentation/screens/privacy_screen.dart';
import 'package:kora/features/settings/presentation/screens/appearance_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        title:  Text('Settings', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),),
       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // const Text(
            //   'Settings',
            //   style: TextStyle(
            //     color: AppColors.primary,
            //     fontSize: 32,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 0.2,
            //   ),
            // ),
            // const SizedBox(height: 28),

            ListItem(
              iconWidget: Container(
                width: 48,
                height: 48,
                decoration:  BoxDecoration(
                  color: AppColors.accent.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: 'Account',
              subtitle: 'Profile info and preferences',
               onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const SizedBox(height: 20),

            NotificationListItem(),
            const SizedBox(height: 20),

            ListItem(
              iconWidget: Container(
                width: 48,
                height: 48,
                decoration:  BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: 'Privacy',
              subtitle: 'Data usage and security controls',
              onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            ),
            // const SizedBox(height: 20),

            // ListItem(
            //   iconWidget: Container(
            //     width: 48,
            //     height: 48,
            //     decoration: BoxDecoration(
            //       color: AppColors.primaryDark.withOpacity(0.4),
            //       shape: BoxShape.circle,
            //     ),
            //     child: const Icon(
            //       Icons.accessibility_new_outlined,
            //       color: AppColors.primary,
            //       size: 22,
            //     ),
            //   ),
            //   title: 'Appearance',
            //   subtitle: 'Themes and text sizing',
            //   onTap: () => Navigator.push(context,
            //             MaterialPageRoute(builder: (_) => const AppearanceScreen())),
            // ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}