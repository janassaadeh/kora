
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class TimerDisplay extends StatelessWidget {
  final String timeLabel;
  const TimerDisplay({super.key, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    // Split at colon for styled rendering
    final parts = timeLabel.split(':');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          parts[0],
          style: AppTextStyles.headingLarge.copyWith(
            fontSize: 60, 
            color: AppColors.primary,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            ':',
            style:  AppTextStyles.headingLarge.copyWith(
            fontSize: 48, 
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.5,
            height: 1,
          ),
          ),
        ),
        Text(
          parts[1],
          style:  AppTextStyles.headingLarge.copyWith(
            fontSize: 60, 
            color: AppColors.primary,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}
