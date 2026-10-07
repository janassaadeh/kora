
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_text_styles.dart';
class RecordingBadge extends StatelessWidget {
  final AnimationController dotCtrl;
  const RecordingBadge({super.key, required this.dotCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: dotCtrl,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'RECORDING',
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}