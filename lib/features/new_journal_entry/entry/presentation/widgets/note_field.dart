
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class NoteField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const NoteField({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 4,
      style:AppTextStyles.body.copyWith(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'How are you really doing?',
        hintStyle: AppTextStyles.body.copyWith(
          fontSize: 15,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:AppRadius.radius,
          borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
      ),
    );
  }
}
