// lib/features/onboarding/presentation/widgets/onboarding_page_view.dart
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import '../../data/models/onboarding_page_model.dart';
import 'phone_mockup_widget.dart';

class OnboardingPageView extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PhoneMockupWidget(illustration: page.illustration),
        const SizedBox(height: 20),
        Text(
          page.title,
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimary,fontSize: 22),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            page.description,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}