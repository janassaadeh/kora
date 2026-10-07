// lib/features/onboarding/presentation/widgets/phone_mockup_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_page.dart';

class PhoneMockupWidget extends StatelessWidget {
  final OnboardingIllustration illustration;

  const PhoneMockupWidget({super.key, required this.illustration});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 384,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF2D3430), width: 7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Notch
          SizedBox(height: 18,),
          Center(
            child: Container(
              width: 80,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF2D3430),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: _buildIllustration(),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return switch (illustration) {
      OnboardingIllustration.voice   => const _VoiceIllustration(),
      OnboardingIllustration.health  => const _HealthIllustration(),
      OnboardingIllustration.insights => const _InsightsIllustration(),
    };
  }
}

// ────────────────────────────────────────
// SCREEN 1 — Voice / Audio
// ────────────────────────────────────────
class _VoiceIllustration extends StatefulWidget {
  const _VoiceIllustration();
  @override
  State<_VoiceIllustration> createState() => _VoiceIllustrationState();
}

class _VoiceIllustrationState extends State<_VoiceIllustration>
    with TickerProviderStateMixin {
  late final List<AnimationController> _barControllers;
  late final AnimationController _pulseController;
  late final AnimationController _blinkController;
  late final List<Animation<double>> _barAnimations;
  late final Animation<double> _pulseAnimation;

  static const _barCount = 7;
  final _rand = Random(42);

  @override
  void initState() {
    super.initState();

    _barControllers = List.generate(_barCount, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + _rand.nextInt(700)),
      )..repeat(reverse: true);
      return c;
    });

    _barAnimations = List.generate(_barCount, (i) {
      final minH = 10.0 + _rand.nextDouble() * 6;
      final maxH = 60.0 + _rand.nextDouble() * 40;
      return Tween<double>(begin: minH, end: maxH)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_barControllers[i]);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulseController);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final c in _barControllers) c.dispose();
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // RECORDING label
          FadeTransition(
            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_blinkController),
            child:  Text(
              'RECORDING',
               style: AppTextStyles.headingSmall.copyWith(color:AppColors.primary)
            ),
          ),
          const SizedBox(height: 2),
           Text(
            '00:42',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          // Animated wave bars
          SizedBox(
            height: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_barCount, (i) {
                final isActive = i > 1 && i < 11;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: AnimatedBuilder(
                    animation: _barAnimations[i],
                    builder: (_, __) => Container(
                      width: 4,
                      height: _barAnimations[i].value,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // const SizedBox(height: 12),
          // Mic button with pulse
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:  AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:  AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 23),
            ),
          ),
          const SizedBox(height: 60),

        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// SCREEN 2 — Health Metrics
// ────────────────────────────────────────
class _HealthIllustration extends StatefulWidget {
  const _HealthIllustration();
  @override
  State<_HealthIllustration> createState() => _HealthIllustrationState();
}

class _HealthIllustrationState extends State<_HealthIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;
  late final Animation<double> _heartScale;

  static const _bars = [0.45, 0.72, 0.35, 0.90, 0.58, 0.65, 0.42];
  final _rand = Random(7);

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: false);
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 44),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));

    _barControllers = List.generate(_bars.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1400 + _rand.nextInt(800)),
      )..repeat(reverse: true);
    });

    _barAnimations = List.generate(_bars.length, (i) {
      final base = _bars[i] * 60;
      return Tween<double>(
        begin: base * 0.5,
        end: base,
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(_barControllers[i]);
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    for (final c in _barControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MetricCard(
            label: 'Heart Rate',
            value: '72 bpm',
            icon: ScaleTransition(
              scale: _heartScale,
              child: const Icon(Icons.favorite, color: Color(0xFFE05555), size: 18),
            ),
          ),
          const SizedBox(height: 8),
          _MetricCard(
            label: 'Daily Steps',
            value: '8,432',
            icon: const Icon(Icons.directions_walk,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 10),
          // Bar chart
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_bars.length, (i) {
                final isActive = i == 1 || i == 3;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedBuilder(
                    animation: _barAnimations[i],
                    builder: (_, __) => Container(
                      width: 14,
                      height: _barAnimations[i].value,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary 
                            : AppColors.primaryDark,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary)),
                Text(value,
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
          icon,
        ],
      ),
    );
  }
}

// ────────────────────────────────────────
// SCREEN 3 — Insights
// ────────────────────────────────────────
class _InsightsIllustration extends StatefulWidget {
  const _InsightsIllustration();
  @override
  State<_InsightsIllustration> createState() => _InsightsIllustrationState();
}

class _InsightsIllustrationState extends State<_InsightsIllustration>
    with TickerProviderStateMixin {
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;
  late final AnimationController _lineController;
  late final AnimationController _sliderController;
  late final Animation<double> _lineOffset;
  late final Animation<double> _sliderFill;

  static const _barHeights = [0.42, 0.75, 0.55, 0.92];
  final _rand = Random(13);

  @override
  void initState() {
    super.initState();

    _barControllers = List.generate(_barHeights.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1600 + _rand.nextInt(800)),
      )..repeat(reverse: true);
    });

    _barAnimations = List.generate(_barHeights.length, (i) {
      final max = _barHeights[i] * 28;
      return Tween<double>(begin: max * 0.5, end: max)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_barControllers[i]);
    });

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _lineOffset = Tween<double>(begin: -1.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_lineController);

    _sliderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _sliderFill = Tween<double>(begin: 0.25, end: 0.78)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_sliderController);
  }

  @override
  void dispose() {
    for (final c in _barControllers) c.dispose();
    _lineController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chart icon box
          Container(
            width: 112,
            // height: 96,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(_barHeights.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2,bottom: 35,top:35),
                  child: AnimatedBuilder(
                    animation: _barAnimations[i],
                    builder: (_, __) => Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 8,
                        height: _barAnimations[i].value,
                        decoration: BoxDecoration(
                          color:AppColors.primary,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 30),
          // Sliding content lines
          AnimatedBuilder(
            animation: _lineOffset,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 7,
                    width: 112,
                    color: AppColors.primaryDark,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (0.8 + _lineOffset.value * 0.12).clamp(0.5, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 7,
                    width: 112,
                    color: AppColors.primaryDark,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (0.6 - _lineOffset.value * 0.1).clamp(0.3, 0.85),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Slider row
          Container(
            width: 112,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.textSecondary, width: 1.5),
                  ),
                  child: const Icon(Icons.sentiment_satisfied,
                      size: 9, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 5,
                      color: AppColors.primary.withOpacity(0.3),
                      alignment: Alignment.centerLeft,
                      child: AnimatedBuilder(
                        animation: _sliderFill,
                        builder: (_, __) => FractionallySizedBox(
                          widthFactor: _sliderFill.value,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color:AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}