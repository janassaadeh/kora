import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

IconData _vitalityIcon(int? score) {
  if (score == null) return Icons.sentiment_neutral;
  if (score >= 80) return Icons.sentiment_very_satisfied;
  if (score >= 60) return Icons.sentiment_satisfied;
  if (score >= 40) return Icons.sentiment_dissatisfied;
  return Icons.sentiment_very_dissatisfied;
}
class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    this.vitalityScore,
    this.onTap,
  });

  final String title;
  final String date;
  final String time;
  final int? vitalityScore;   // <-- new
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        // decoration: BoxDecoration(
        //   color: AppColors.primaryDark.withOpacity(0.00),
        //   borderRadius: BorderRadius.circular(9999),
        // ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Icon(
                  _vitalityIcon(vitalityScore),
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$date • $time',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB0BAB0), size: 20),
          ],
        ),
      ),
    );
  }
}