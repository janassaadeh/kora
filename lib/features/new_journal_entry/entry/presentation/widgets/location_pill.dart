
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/pill_chip.dart';

class LocationPill extends StatelessWidget {
  final String? currentCity;
  final bool loading;
  const LocationPill({this.currentCity, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 11,
              height: 11,
              child: AppLoader(
                strokeWidth: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LOCATING...',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)
            ),
          ],
        ),
      );
    }

    final hasLocation = currentCity != null && currentCity!.isNotEmpty;
    // No onTap — location is set automatically from GPS, no dialog needed.
    return PillChip(
      icon: hasLocation ? Icons.location_on : Icons.location_on_outlined,
      label: hasLocation ? currentCity!.toUpperCase() : 'NO LOCATION',
    );
  }
}
