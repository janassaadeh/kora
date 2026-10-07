// lib/features/onboarding/presentation/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _circleCtrl;
  late final AnimationController _iconCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _rippleCtrl;
  late final AnimationController _loaderCtrl;
  late final AnimationController _swayCtrl;

  late final Animation<double> _circleScale;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  late final Animation<double> _titleOffset;
  late final Animation<double> _titleFade;
  late final Animation<double> _swayAngle;

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _circleScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 30),
    ]).animate(_circleCtrl);

    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(_iconCtrl);
    _iconFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: const Interval(0.0, 0.4)),
    );

    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _titleOffset = Tween(begin: 16.0, end: 0.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_titleCtrl);
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: const Interval(0.0, 0.4)),
    );

    _rippleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
    _loaderCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

    _swayCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500))..repeat(reverse: true);
    _swayAngle = Tween(begin: -0.035, end: 0.035)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_swayCtrl);

    _sequence();
  }

  Future<void> _sequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _circleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _iconCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1700));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _iconCtrl.dispose();
    _titleCtrl.dispose();
    _rippleCtrl.dispose();
    _loaderCtrl.dispose();
    _swayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2E8),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple rings
          Center(
            child: AnimatedBuilder(
              animation: _rippleCtrl,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [0.0, 1.0 / 3.0, 2.0 / 3.0].map((delay) {
                  final t = ((_rippleCtrl.value - delay) % 1.0).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: (0.15 * (1 - t)).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.0 + t * 0.6,
                      child: Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Centered column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle + icon
              AnimatedBuilder(
                animation: Listenable.merge([_circleCtrl, _iconCtrl, _swayCtrl]),
                builder: (_, __) => Transform.scale(
                  scale: _circleScale.value,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: _swayAngle.value,
                        alignment: const Alignment(0, 0.6),
                        child: FadeTransition(
                          opacity: _iconFade,
                          child: Transform.scale(
                            scale: _iconScale.value,
                            child: Image.asset(
                              'assets/icons/leaf_icon.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              AnimatedBuilder(
                animation: _titleCtrl,
                builder: (_, __) => Opacity(
                  opacity: _titleFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _titleOffset.value),
                    child:  Text(
                      'Kora AI',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Wave loader at bottom
          Positioned(
            bottom: 48,
            child: AnimatedBuilder(
              animation: _loaderCtrl,
              builder: (_, __) {
                const delays = [0.0, 0.1, 0.2, 0.3, 0.4];
                const maxHeights = [8.0, 12.0, 16.0, 12.0, 8.0];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    final t = ((_loaderCtrl.value - delays[i]) % 1.0).clamp(0.0, 1.0);
                    final scale = 0.35 + 0.65 * (t < 0.5 ? 2 * t : 2 * (1 - t));
                    final opacity = 0.3 + 0.65 * (t < 0.5 ? 2 * t : 2 * (1 - t));
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 2.5,
                      height: maxHeights[i] * scale,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}