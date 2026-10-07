import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class ListItem extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ListItem({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.00),
          borderRadius: AppRadius.radius
          
        ),
        child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary,fontSize: 18),
                ),
                // const SizedBox(height: 3),
                // Text(
                //   subtitle,
                //   style:AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary, height: 1.4,fontSize: 14),
                // ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    ));
  }
}