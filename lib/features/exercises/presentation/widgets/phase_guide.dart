import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';

/// "How it works" card explaining each phase of the breathing pattern.
class PhaseGuide extends StatelessWidget {
  final BreathPattern pattern;
  final Color accent;

  const PhaseGuide({
    super.key,
    required this.pattern,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final steps = <Map<String, dynamic>>[
      {
        'icon': Icons.arrow_upward_rounded,
        'title': 'Inhale',
        'desc':
            '${pattern.inhaleSeconds}s — breathe in slowly through your nose',
      },
      if (pattern.holdSeconds > 0)
        {
          'icon': Icons.pause_rounded,
          'title': 'Hold',
          'desc': '${pattern.holdSeconds}s — hold gently at the top',
        },
      {
        'icon': Icons.arrow_downward_rounded,
        'title': 'Exhale',
        'desc':
            '${pattern.exhaleSeconds}s — release fully through your mouth',
      },
      if (pattern.holdOutSeconds > 0)
        {
          'icon': Icons.pause_rounded,
          'title': 'Rest',
          'desc':
              '${pattern.holdOutSeconds}s — rest at the bottom before the next breath',
        },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.07),
        borderRadius: AppRadius.radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style:
                AppTextStyles.body.copyWith(color: AppColors.primary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final isLast = entry.key == steps.length - 1;
            final step = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      size: 14,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['desc'] as String,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}