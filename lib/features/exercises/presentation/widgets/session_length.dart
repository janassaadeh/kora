import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class SessionLength extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const SessionLength({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
          Text('SESSION LENGTH', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          // Text('Mindful Duration', style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSecondary)),
        ]),
        SizedBox(height: 20),
        Row(
          children: [3, 5, 10].map((m) {
            final active = m == selected;
            return Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                onTap: () => onSelect(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.15),
                    borderRadius: AppRadius.radius,
                  ),
                  child: Text(
                    '$m min',
                    style: AppTextStyles.body.copyWith(color: active ? AppColors.card : AppColors.textSecondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
