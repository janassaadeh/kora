// lib/features/auth/presentation/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import 'package:kora/core/common/app_textfield.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          hint:hint,
          suffixIcon: suffixIcon,
        )
      ],
    );
  }
}