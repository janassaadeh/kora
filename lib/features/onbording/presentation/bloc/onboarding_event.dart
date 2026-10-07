// lib/features/onboarding/presentation/bloc/onboarding_event.dart
part of 'onboarding_bloc.dart';

abstract class OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;
  OnboardingPageChanged(this.pageIndex);
}

class OnboardingNextPressed extends OnboardingEvent {}

class OnboardingSkipped extends OnboardingEvent {}

class OnboardingCompleted extends OnboardingEvent {}