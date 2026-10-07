import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.analytics_rounded, Icons.analytics_sharp, 'Analysis'),
    (Icons.edit_note, Icons.edit_note, 'Journals'),
    (Icons.self_improvement_rounded, Icons.self_improvement_sharp, 'Exercises'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        // border: Border(top: BorderSide(color: Color(0xFFD4E0D4), width: 0.5)),
      ),
      padding: const EdgeInsets.only(bottom: 35,left: 10,right:10,top:10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final isActive = i == currentIndex;
            final item = _items[i];
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 21),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.tertiary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.$1 : item.$2,
                      size: 22,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$3,
                      style: AppTextStyles.body.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    // if (isActive) ...[
                    //   const SizedBox(height: 3),
                    //   Container(
                    //     width: 4,
                    //     height: 4,
                    //     decoration: const BoxDecoration(
                    //       color: Color(0xFF2C5A30),
                    //       shape: BoxShape.circle,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}