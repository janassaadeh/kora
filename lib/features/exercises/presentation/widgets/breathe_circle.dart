import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class BreatheCircle extends StatelessWidget {
  final AnimationController breatheCtrl;
  final AnimationController glowCtrl;
  final Animation<double> circleScale;
  final Animation<double> circleOpacity;
  final Animation<double> glowScale;
  final bool running;
  final String phase;
  final VoidCallback onTap;

  const BreatheCircle({
    required this.breatheCtrl,
    required this.glowCtrl,
    required this.circleScale,
    required this.circleOpacity,
    required this.glowScale,
    required this.running,
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 224,
        height: 224,
        child: AnimatedBuilder(
          animation: Listenable.merge([breatheCtrl, glowCtrl]),
          builder: (_, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Transform.scale(
                  scale: glowScale.value,
                  child: Container(
                    width: 224,
                    height: 224,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent
                          .withOpacity(0.27 * (running ? circleOpacity.value : 0.7)),
                    ),
                  ),
                ),
                // Breathing ring
                Transform.scale(
                  scale: running ? circleScale.value : 1.0,
                  child: Opacity(
                    opacity: running ? circleOpacity.value : 0.6,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.3),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.55),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        running ? phase : 'INHALE',
                        key: ValueKey(phase),
                        style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary,fontSize:14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      running ? '' : 'START',
                      style:AppTextStyles.headingLarge.copyWith(color: AppColors.primary, fontSize: 26, height: 1.2),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}