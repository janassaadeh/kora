class OnboardingPage {
  final String title;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

enum OnboardingIllustration { voice, health, insights }