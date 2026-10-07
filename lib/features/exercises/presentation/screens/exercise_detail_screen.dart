import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora/core/theme/app_colors.dart';

import 'package:kora/features/exercises/presentation/widgets/breath_pattern.dart';
import 'package:kora/features/exercises/presentation/widgets/exercise_header.dart';
import 'package:kora/features/exercises/presentation/widgets/hero_breathing_circle.dart';
import 'package:kora/features/exercises/presentation/widgets/phase_guide.dart';
import 'package:kora/features/exercises/presentation/widgets/phase_ratio_chips.dart';
import 'package:kora/features/exercises/presentation/widgets/session_progress_bar.dart';
import 'package:kora/features/exercises/presentation/widgets/start_button_session.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ExerciseDetailScreen extends StatefulWidget {
  final BreathPattern pattern;
  final int sessionMinutes;
  final String? imageUrl;

  const ExerciseDetailScreen({
    super.key,
    required this.pattern,
    this.sessionMinutes = 3,
    this.imageUrl,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  late AnimationController _circleCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _entryCtrl;

  late Animation<double> _circleScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _entryFade;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _running = false;
  BreathPhase _phase = BreathPhase.idle;
  int _countdown = 0;
  int _cyclesCompleted = 0;
  Timer? _phaseTimer;
  Timer? _countdownTimer;

  // ── Helpers ───────────────────────────────────────────────────────────────
  BreathPattern get p => widget.pattern;

  int get _totalCycles =>
      ((widget.sessionMinutes * 60) / p.cycleDuration).ceil();

  String get _activeChipLabel {
    switch (_phase) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.holdIn:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.holdOut:
        return 'Hold';
      case BreathPhase.idle:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(vsync: this);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _progressCtrl = AnimationController(vsync: this);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _circleScale = Tween<double>(begin: 0.72, end: 1.18).animate(
      CurvedAnimation(parent: _circleCtrl, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.15, end: 0.38).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  // ── Session control ───────────────────────────────────────────────────────

  void _startSession() {
    _hapticSequence(
      [HapticFeedback.heavyImpact, HapticFeedback.heavyImpact],
      gap: 130,
    );
    setState(() {
      _running = true;
      _cyclesCompleted = 0;
    });
    _progressCtrl.duration = Duration(seconds: widget.sessionMinutes * 60);
    _progressCtrl.forward(from: 0);
    _startInhale();
  }

  void _stopSession() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _circleCtrl.animateBack(
      0,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
    );
    _progressCtrl.stop();
    HapticFeedback.heavyImpact();
    setState(() {
      _running = false;
      _phase = BreathPhase.idle;
      _countdown = 0;
    });
  }

  void _onSessionComplete() {
    _stopSession();
    _hapticSequence(
      [
        HapticFeedback.heavyImpact,
        HapticFeedback.mediumImpact,
        HapticFeedback.lightImpact,
      ],
      gap: 180,
    );
  }

  // ── Phase sequencing ──────────────────────────────────────────────────────

  void _startInhale() {
    if (!mounted || !_running) return;
    setState(() {
      _phase = BreathPhase.inhale;
      _countdown = p.inhaleSeconds;
    });
    _circleCtrl.duration = Duration(seconds: p.inhaleSeconds);
    _circleCtrl.forward(from: _circleCtrl.value);
    _hapticSequence(
      [
        HapticFeedback.lightImpact,
        HapticFeedback.lightImpact,
        HapticFeedback.mediumImpact,
      ],
      gap: 160,
    );
    _startCountdown(p.inhaleSeconds, _afterInhale);
  }

  void _afterInhale() {
    if (!mounted || !_running) return;
    if (p.holdSeconds > 0) {
      _startHoldIn();
    } else {
      _startExhale();
    }
  }

  void _startHoldIn() {
    if (!mounted || !_running) return;
    setState(() {
      _phase = BreathPhase.holdIn;
      _countdown = p.holdSeconds;
    });
    _circleCtrl.stop();
    HapticFeedback.selectionClick();
    _startCountdown(p.holdSeconds, _startExhale);
  }

  void _startExhale() {
    if (!mounted || !_running) return;
    setState(() {
      _phase = BreathPhase.exhale;
      _countdown = p.exhaleSeconds;
    });
    _circleCtrl.duration = Duration(seconds: p.exhaleSeconds);
    _circleCtrl.reverse();
    _hapticSequence(
      [
        HapticFeedback.mediumImpact,
        HapticFeedback.lightImpact,
        HapticFeedback.selectionClick,
      ],
      gap: 210,
    );
    _startCountdown(p.exhaleSeconds, _afterExhale);
  }

  void _afterExhale() {
    if (!mounted || !_running) return;
    setState(() => _cyclesCompleted++);
    if (_cyclesCompleted >= _totalCycles) {
      _onSessionComplete();
      return;
    }
    if (p.holdOutSeconds > 0) {
      _startHoldOut();
    } else {
      _startInhale();
    }
  }

  void _startHoldOut() {
    if (!mounted || !_running) return;
    setState(() {
      _phase = BreathPhase.holdOut;
      _countdown = p.holdOutSeconds;
    });
    _circleCtrl.stop();
    HapticFeedback.selectionClick();
    _startCountdown(p.holdOutSeconds, _startInhale);
  }

  void _startCountdown(int seconds, VoidCallback onDone) {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown = (_countdown - 1).clamp(0, seconds));
    });

    _phaseTimer = Timer(Duration(seconds: seconds), () {
      _countdownTimer?.cancel();
      onDone();
    });
  }

  // ── Haptics ───────────────────────────────────────────────────────────────

  Future<void> _hapticSequence(
    List<Future<void> Function()> impacts, {
    int gap = 180,
  }) async {
    for (int i = 0; i < impacts.length; i++) {
      await impacts[i]();
      if (i < impacts.length - 1) {
        await Future.delayed(Duration(milliseconds: gap));
      }
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _circleCtrl.dispose();
    _glowCtrl.dispose();
    _progressCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _entryFade,
        child: SafeArea(
          child: Column(
            children: [
              ExerciseHeader(
                pattern: p,
                onBack: () {
                  if (_running) _stopSession();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        HeroBreathingCircle(
                          circleCtrl: _circleCtrl,
                          glowCtrl: _glowCtrl,
                          circleScale: _circleScale,
                          glowOpacity: _glowOpacity,
                          running: _running,
                          phase: _phase,
                          countdown: _countdown,
                          imageUrl: widget.imageUrl,
                          icon: p.icon,
                          accent: accent,
                          onTap: _running ? _stopSession : _startSession,
                        ),
                        const SizedBox(height: 36),
                        PhaseRatioChips(
                          pattern: p,
                          running: _running,
                          activeChipLabel: _activeChipLabel,
                          accent: accent,
                        ),
                        const SizedBox(height: 32),
                        SessionProgressBar(
                          progressCtrl: _progressCtrl,
                          running: _running,
                          cyclesCompleted: _cyclesCompleted,
                          totalCycles: _totalCycles,
                          sessionMinutes: widget.sessionMinutes,
                          accent: accent,
                        ),
                        const SizedBox(height: 36),
                        StartSessionButton(
                          running: _running,
                          accent: accent,
                          onTap: _running ? _stopSession : _startSession,
                        ),
                        const SizedBox(height: 32),
                        PhaseGuide(pattern: p, accent: accent),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}