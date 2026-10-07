
import 'package:flutter/widgets.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';

class SmallCard extends StatelessWidget {
  final Widget child;

  const SmallCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.15),
        borderRadius: AppRadius.radius,
      ),
      child: child,
    );
  }
}