import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const StatTile({super.key, 
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: AppRadius.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimary)

          ),
          Text(
            unit,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)

          ),
        ],
      ),
    );
  }
}
