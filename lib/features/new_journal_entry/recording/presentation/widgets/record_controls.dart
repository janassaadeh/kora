
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/control_button.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/play_pause_btn.dart';

class RecordControls extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onToggle;
  final VoidCallback cancelFct;
  final VoidCallback finishFct;


  const RecordControls({super.key, required this.isPaused, required this.onToggle, required this.cancelFct, required this.finishFct});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ControlBtn(
          icon: Icons.close_rounded,
          label: 'CANCEL',
          color: AppColors.textSecondary,
          size: 56,
          onTap: cancelFct
        ),
        PausePlayBtn(isPaused: isPaused, onTap: onToggle),
        ControlBtn(
          icon: Icons.check_rounded,
          label: 'FINISH',
          color: AppColors.primary,
          size: 56,
          onTap: finishFct
        ),
      ],
    );
  }
}