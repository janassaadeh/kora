import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';
import 'package:kora/features/exercises/presentation/widgets/breathe_circle.dart';
import 'package:kora/features/exercises/presentation/widgets/exercise_header.dart';
import 'package:kora/features/exercises/presentation/widgets/haptics_toggle.dart';
import 'package:kora/features/exercises/presentation/widgets/quick_reset_card.dart';
import 'package:kora/features/exercises/presentation/widgets/session_length.dart';
import 'package:kora/features/exercises/presentation/screens/exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  bool _running = false;
  int _selectedMin = 3;
  bool _haptic = true;
  String _phase = 'START';

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _breatheCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _entryCtrl;

  late Animation<double> _circleScale;
  late Animation<double> _circleOpacity;
  late Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _circleScale = Tween<double>(begin: 0.72, end: 1.18).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
    _circleOpacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
    _glowScale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _breatheCtrl.addStatusListener(_onBreatheStatus);
  }

  // ── Haptic patterns ───────────────────────────────────────────────────────

  Future<void> _hapticInhale() async {
    if (!_haptic) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.mediumImpact();
  }

  Future<void> _hapticExhale() async {
    if (!_haptic) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 220));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 260));
    await HapticFeedback.selectionClick();
  }

  Future<void> _hapticSessionStart() async {
    if (!_haptic) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }

  Future<void> _hapticSessionStop() async {
    if (!_haptic) return;
    await HapticFeedback.heavyImpact();
  }

  // ── Breath phase listener ─────────────────────────────────────────────────
  void _onBreatheStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.forward) {
      setState(() => _phase = 'INHALE');
      _hapticInhale();
    } else if (status == AnimationStatus.reverse) {
      setState(() => _phase = 'EXHALE');
      _hapticExhale();
    }
  }

  void _toggleBreathe() {
    final wasRunning = _running;
    setState(() {
      _running = !_running;
      if (_running) {
        _phase = 'INHALE';
        _breatheCtrl.repeat(reverse: true);
      } else {
        _phase = 'START';
        _breatheCtrl.animateBack(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
        );
      }
    });
    wasRunning ? _hapticSessionStop() : _hapticSessionStart();
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryCtrl,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          children: [
            // ── Breathe circle ──────────────────────────────────────
            Center(
              child: BreatheCircle(
                breatheCtrl: _breatheCtrl,
                glowCtrl: _glowCtrl,
                circleScale: _circleScale,
                circleOpacity: _circleOpacity,
                glowScale: _glowScale,
                running: _running,
                phase: _phase,
                onTap: _toggleBreathe,
              ),
            ),
            const SizedBox(height: 32),

            // ── Session length ─────────────────────────────────────
            SessionLength(
              selected: _selectedMin,
              onSelect: (v) => setState(() => _selectedMin = v),
            ),
            const SizedBox(height: 30),

            // ── Haptics toggle ─────────────────────────────────────
            HapticsToggle(
              enabled: _haptic,
              onToggle: () => setState(() => _haptic = !_haptic),
            ),
            const SizedBox(height: 30),

            // ── Quick resets ───────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child:Text('QUICK RESETS', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),

            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                QuickResetCard(
                  pattern: kForestAir,
                  sessionMinutes: _selectedMin,
                  imageUrl: 'https://i.pinimg.com/736x/9c/4b/ed/9c4bed6a11898436740cb911c67288a9.jpg',
                ),
                QuickResetCard(
                  pattern: kTidalFlow,
                  sessionMinutes: _selectedMin,
                  imageUrl: 'https://i.pinimg.com/736x/04/19/40/041940c6cb7ec544aaf728bc330f9d58.jpg',
                ),
                QuickResetCard(
                  pattern: kEveningDew,
                  sessionMinutes: _selectedMin,
                  imageUrl: 'https://i.pinimg.com/736x/88/0e/df/880edfc95f6f7eb49193d0530a7bfbbb.jpg',
                ),
                QuickResetCard(
                  pattern: kMountainBreath,
                  sessionMinutes: _selectedMin,
                  imageUrl: 'https://i.pinimg.com/736x/94/ca/26/94ca2657f9f20ed2184da657dffe5c49.jpg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}