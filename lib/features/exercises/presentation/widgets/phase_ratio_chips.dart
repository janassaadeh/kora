import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';

/// Row of chips showing inhale/hold/exhale/hold-out durations,
/// highlighting whichever phase is currently active.
class PhaseRatioChips extends StatelessWidget {
  final BreathPattern pattern;
  final bool running;
  final String activeChipLabel;
  final Color accent;

  const PhaseRatioChips({
    super.key,
    required this.pattern,
    required this.running,
    required this.activeChipLabel,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final phases = <Map<String, dynamic>>[
      {'label': 'Inhale', 'secs': pattern.inhaleSeconds},
      if (pattern.holdSeconds > 0)
        {'label': 'Hold', 'secs': pattern.holdSeconds},
      {'label': 'Exhale', 'secs': pattern.exhaleSeconds},
      if (pattern.holdOutSeconds > 0)
        {'label': 'Hold', 'secs': pattern.holdOutSeconds},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: phases.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value['label'] as String;
          final secs = entry.value['secs'] as int;
          final isActive = running && activeChipLabel == label;

          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? accent.withOpacity(0.2)
                      : AppColors.textSecondary.withOpacity(0.08),
                  borderRadius: AppRadius.radius,
                  border: Border.all(
                    color: isActive ? accent : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${secs}s',
                      style: AppTextStyles.body.copyWith(
                        color: isActive ? accent : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      label,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isActive
                            ? accent.withOpacity(0.8)
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (idx < phases.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.textSecondary.withOpacity(0.4),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}