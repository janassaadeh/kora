// lib/features/onboarding/presentation/bloc/onboarding_state.dart
part of 'onboarding_bloc.dart';

class OnboardingState {
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
  });

  bool get isLastPage => currentPage == 2;

  OnboardingState copyWith({int? currentPage, bool? isCompleted}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}