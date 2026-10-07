import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';

/// The large animated breathing circle in the middle of the screen.
class HeroBreathingCircle extends StatelessWidget {
  final AnimationController circleCtrl;
  final AnimationController glowCtrl;
  final Animation<double> circleScale;
  final Animation<double> glowOpacity;
  final bool running;
  final BreathPhase phase;
  final int countdown;
  final String? imageUrl;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const HeroBreathingCircle({
    super.key,
    required this.circleCtrl,
    required this.glowCtrl,
    required this.circleScale,
    required this.glowOpacity,
    required this.running,
    required this.phase,
    required this.countdown,
    required this.imageUrl,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  String get _phaseLabel {
    switch (phase) {
      case BreathPhase.inhale:
        return 'INHALE';
      case BreathPhase.holdIn:
        return 'HOLD';
      case BreathPhase.exhale:
        return 'EXHALE';
      case BreathPhase.holdOut:
        return 'HOLD';
      case BreathPhase.idle:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 240,
          height: 240,
          child: AnimatedBuilder(
            animation: Listenable.merge([circleCtrl, glowCtrl]),
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Blurred background image (from Quick Reset card)
                  if (imageUrl != null)
                    ClipOval(
                      child: SizedBox(
                        width: 232,
                        height: 232,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: accent.withOpacity(0.6)),
                              ),
                            ),
                            // Scrim so the ring/text stay readable
                            Container(
                              color: AppColors.background.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Outer glow
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(glowOpacity.value),
                    ),
                  ),
                  // Breathing ring
                  Transform.scale(
                    scale: running ? circleScale.value : 1.0,
                    child: Container(
                      width: 158,
                      height: 158,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.22),
                        border: Border.all(
                          color: accent.withOpacity(0.6),
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  // Labels
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!running) ...[
                        Icon(icon, size: 28, color: accent),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to begin',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ] else ...[
                        if (countdown > 0)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              '$countdown',
                              key: ValueKey<int>(countdown),
                              style: AppTextStyles.headingLarge.copyWith(
                                color: accent,
                                fontSize: 40,
                                height: 1,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: Text(
                            _phaseLabel,
                            key: ValueKey<BreathPhase>(phase),
                            style: AppTextStyles.headingSmall.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}