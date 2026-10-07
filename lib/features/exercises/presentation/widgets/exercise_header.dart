import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';

/// Top bar for the exercise detail screen: back button, title, tagline, icon.
class ExerciseHeader extends StatelessWidget {
  final BreathPattern pattern;
  final VoidCallback onBack;

  const ExerciseHeader({
    super.key,
    required this.pattern,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          // Standard platform back button (iOS chevron / Android arrow).
          const BackButton(color: AppColors.primary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pattern.name,
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.primary),
              ),
              // Text(
              //   pattern.tagline,
              //   style: AppTextStyles.headingSmall.copyWith(
              //     color: AppColors.textSecondary,
              //     fontSize: 13,
              //   ),
              // ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(pattern.icon, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}