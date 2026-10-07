// lib/features/onboarding/presentation/pages/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import '../../data/models/onboarding_page_model.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page_view.dart';
import '../widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.currentPage) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
        if (state.isCompleted) widget.onCompleted();
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top bar - keeps structural layout identical by replacing text with transparent spacer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  key: const ValueKey('top_bar'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kora AI',
                        style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                      ),
                      AnimatedOpacity(
                        opacity: state.isLastPage ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton(
                          onPressed: state.isLastPage 
                              ? null 
                              : () => context.read<OnboardingBloc>().add(OnboardingSkipped()),
                          child: Text(
                            'Skip',
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingPageModel.pages.length,
                    onPageChanged: (i) => context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(i)),
                    itemBuilder: (_, i) => OnboardingPageView(
                      page: OnboardingPageModel.pages[i],
                    ),
                  ),
                ),

                // Bottom section - maintains constant size layout to prevent screen jumping/overflows
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PageIndicator(
                        count: OnboardingPageModel.pages.length,
                        current: state.currentPage,
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        opacity: state.isLastPage ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isLastPage
                                ? () => context.read<OnboardingBloc>().add(OnboardingCompleted())
                                : null, // Disabled when invisible so it can't be accidentally tapped
                            child: Text(
                              'Begin Journey',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}