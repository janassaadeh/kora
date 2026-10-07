import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class SocialAuthRow extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  const SocialAuthRow({super.key, this.onGoogleTap, this.onAppleTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.primaryDark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Or continue with',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              onTap: onGoogleTap ?? () {},
              child: Image.asset('assets/icons/google.png', width: 22, height: 22),
            ),
            const SizedBox(width: 12),
            _SocialButton(
              onTap: onAppleTap ?? () {},
              child: Image.asset('assets/icons/apple.png', width: 22, height: 22),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}