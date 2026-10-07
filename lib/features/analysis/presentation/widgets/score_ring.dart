import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/analysis/presentation/widgets/ring_painter.dart';
class ScoreRing extends StatelessWidget {
  final int score;
  final double progress;

  const ScoreRing({
    required this.score,
    required this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final vitality = getVitalityLabel(score);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.32),
                ),
              ),
            ),
        
            CustomPaint(
              size: const Size(210, 210),
              painter: RingPainter(progress: progress),
              child: SizedBox(
                width: 210,
                height: 210,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vitality Score',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
        
                    Text(
                      '$score',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: 50,
                        color: AppColors.primary,
                      ),
                    ),
        
                    Text(
                      vitality.label,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
            Text(
              getVitalityLabel(score).insight,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 35),
      ],
    );
  }
}
class VitalityLabel {
  final String label;
  final String insight;

  const VitalityLabel(this.label, this.insight);
}

VitalityLabel getVitalityLabel(int score) {
  if (score >= 80) {
    return const VitalityLabel(
      "Elevated",
      "Your system is in a highly adaptive state with strong cognitive efficiency and emotional stability.",
    );
  }

  if (score >= 60) {
    return const VitalityLabel(
      "Good",
      "Your physiological and emotional signals are balanced, supporting steady performance and focus.",
    );
  }

  if (score >= 40) {
    return const VitalityLabel(
      "Moderate",
      "Some variability in your signals suggests mild stress or reduced recovery capacity.",
    );
  }

  return const VitalityLabel(
    "Low",
    "Your system shows signs of fatigue and reduced recovery. Prioritizing rest may be beneficial.",
  );
}