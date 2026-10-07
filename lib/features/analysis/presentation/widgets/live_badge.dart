import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class LiveBadge extends StatefulWidget {
  @override
  State<LiveBadge> createState() => LiveBadgeState();
}

class LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.8),
        borderRadius: AppRadius.radius,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FadeTransition(
          opacity: _ctrl,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text('Live Cadence', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}
