import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/step_progress_bar.dart';

class EntrySheetHeader extends StatelessWidget {
  // final String title;
  final int currentStep; // 1-based
  final int totalSteps;
  final VoidCallback onClose;

  const EntrySheetHeader({
    super.key,
    // required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 15),
        StepProgressBar(current: currentStep, total: totalSteps),
        const SizedBox(height: 20),
      ],
    );
  }
}