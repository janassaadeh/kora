import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class EntryBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const EntryBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textSecondary.withOpacity(0.08),
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      child: Text(
        'Back',
        style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
      ),
    ));
  }
}
