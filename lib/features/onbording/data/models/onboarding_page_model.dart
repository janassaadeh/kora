// lib/features/onboarding/data/models/onboarding_page_model.dart
import '../../domain/entities/onboarding_page.dart';

class OnboardingPageModel extends OnboardingPage {
  const OnboardingPageModel({
    required super.title,
    required super.description,
    required super.illustration,
  });

  static const List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: 'Speak your mind.',
      description:
          "Share your thoughts through voice or text. Kora's on-device AI analyzes your patterns to understand your emotional landscape without ever leaving your phone.",
      illustration: OnboardingIllustration.voice,
    ),
    OnboardingPageModel(
      title: 'Listen to your body.',
      description:
          'By syncing with your heart rate and activity, we bridge the gap between how you feel and how your body reacts—giving you a complete picture of your wellness.',
      illustration: OnboardingIllustration.health,
    ),
    OnboardingPageModel(
      title: 'Reflect on your input.',
      description:
          'Turn daily check-ins into meaningful insights. Track your stress trends over time and receive AI-driven guidance tailored to your unique needs.',
      illustration: OnboardingIllustration.insights,
    ),
  ];
}