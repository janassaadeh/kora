import 'package:flutter/material.dart';
import 'package:kora/core/common/small_card.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String diffrence;
  final String label;

  final Color? iconColor;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.diffrence,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cleanedDifference = diffrence.replaceAll('%', '').trim();

    final isPositive = cleanedDifference.startsWith('+');
    final isNegative =
        cleanedDifference.startsWith('-') &&
        cleanedDifference != '-0';

    final isSteady =
        cleanedDifference == '0' ||
        cleanedDifference == '-0' ||
        cleanedDifference == '+0';

    return SmallCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 25,
                color: iconColor ?? AppColors.textSecondary,
              ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.accent
                        : isNegative
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: AppRadius.radius,
                  ),
                  child: Text(
                    isSteady ? 'Steady' : diffrence,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isPositive
                          ? AppColors.primary
                          : isNegative
                              ? AppColors.error
                              : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),

        Text(
            label,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 9),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style:AppTextStyles.headingLarge.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),

                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          
        ],
      ),
    );
  }
}
