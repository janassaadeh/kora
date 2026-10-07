import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

/// Session progress label + linear progress indicator.
class SessionProgressBar extends StatelessWidget {
  final AnimationController progressCtrl;
  final bool running;
  final int cyclesCompleted;
  final int totalCycles;
  final int sessionMinutes;
  final Color accent;

  const SessionProgressBar({
    super.key,
    required this.progressCtrl,
    required this.running,
    required this.cyclesCompleted,
    required this.totalCycles,
    required this.sessionMinutes,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressCtrl,
      builder: (_, __) {
        final progress = running ? progressCtrl.value : 0.0;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session Progress',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  running
                      ? '$cyclesCompleted / $totalCycles cycles'
                      : '$sessionMinutes min · $totalCycles cycles',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: AppRadius.radius,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.textSecondary.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        );
      },
    );
  }
}