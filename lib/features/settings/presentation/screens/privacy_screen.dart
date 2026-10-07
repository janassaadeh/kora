// lib/features/settings/presentation/screens/privacy_screen.dart
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          'Privacy',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Built around your privacy',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kora only listens when you check in, and keeps your data '
              'on your device.',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 28),

            _PrivacyFeatureCard(
              icon: Icons.smartphone_outlined,
              title: 'On-device processing',
              description:
                  'Voice recordings and journal entries are analyzed '
                  'on your phone.',
            ),
            const SizedBox(height: 14),
            _PrivacyFeatureCard(
              icon: Icons.location_off_outlined,
              title: 'No location tracking',
              description: 'Kora never accesses your GPS or location.',
            ),
            const SizedBox(height: 14),
            _PrivacyFeatureCard(
              icon: Icons.visibility_off_outlined,
              title: 'No background surveillance',
              description:
                  'Data is only gathered when you start a check-in.',
            ),
            const SizedBox(height: 14),
            _PrivacyFeatureCard(
              icon: Icons.tune_outlined,
              title: 'You stay in control',
              description:
                  'Heart rate, HRV, and step data are used only with '
                  'your permission.',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PrivacyFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: AppColors.textPrimary.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}