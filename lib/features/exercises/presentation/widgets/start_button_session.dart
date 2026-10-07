import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

/// The primary "Start Session" / "End Session" pill button.
class StartSessionButton extends StatelessWidget {
  final bool running;
  final Color accent;
  final VoidCallback onTap;

  const StartSessionButton({
    super.key,
    required this.running,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: running ? AppColors.textSecondary.withOpacity(0.1) : accent,
          borderRadius:AppRadius.radius,
        ),
        child: Center(
          child: Text(
            running ? 'End Session' : 'Start Session',
            style: AppTextStyles.body.copyWith(
              color: running ? AppColors.textSecondary : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}