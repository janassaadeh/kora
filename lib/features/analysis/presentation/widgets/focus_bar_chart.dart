
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
// ─── Focus Bar Chart ──────────────────────────────────────────────────────────

class FocusBarChart extends StatelessWidget {
  final Animation<double> animation;
  final List<double> values;
  final List<String> dayLabels;

  const FocusBarChart({super.key, required this.animation, required this.values, required this.dayLabels});

  // static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  // static const _vals = [0.52, 0.64, 0.78, 0.46, 0.92, 0.68, 0.55];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => SizedBox(
        height: 170,
        child: Column(children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: values.asMap().entries.map((e) => AnimatedContainer(
                duration: Duration(milliseconds: 280 + e.key * 55),
                width: 41.5,
                height: 160.0 * e.value * animation.value,
                decoration: BoxDecoration(
                  color: e.key == 4
                      ? AppColors.primary
                      : AppColors.accent.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels.map((d) => Row(
              children: [
                const SizedBox(width: 9),
                Text(d,
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 9),
              
              ],
            )).toList(),
          ),
        ]),
      ),
    );
  }
}
