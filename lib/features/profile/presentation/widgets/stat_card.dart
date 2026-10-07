import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool extraIcon;
  final bool accent;

  const StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.extraIcon = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.00),
          borderRadius: BorderRadius.circular(9999),
          
        ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:  BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary,fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary, height: 1.4, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
