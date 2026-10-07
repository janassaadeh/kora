
import 'package:flutter/widgets.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class PillChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const PillChip({this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style:AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)
            ),
          ],
        ),
      ),
    );
  }
}
