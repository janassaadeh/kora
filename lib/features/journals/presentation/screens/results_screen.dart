import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/core/utils/audio_normalizer.dart';
import 'package:kora/features/analysis/presentation/widgets/focus_bar_chart.dart';
import 'package:kora/features/analysis/presentation/widgets/metric_card.dart';
import 'package:kora/features/analysis/presentation/widgets/score_ring.dart';
import 'package:kora/features/analysis/presentation/widgets/voice_analysis_card.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';

class ResultScreen extends StatefulWidget {
  final NewEntry entry;

  /// The entry that happened immediately before this one in time.
  /// Used to compute the real "difference" shown on the metric cards.
  /// Null when [entry] is the oldest one on record — there's nothing
  /// to compare it against.
  final NewEntry? previousEntry;

  const ResultScreen({
    super.key,
    required this.entry,
    this.previousEntry,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterCtrl;
  late Animation<double> _scoreProg;
  late Animation<double> _ringProg;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _chartProg;

  // Computed once — entry/previousEntry don't change during this screen's life.
  late final String _stepsDiff;
  late final String _heartRateDiff;

  @override
  void initState() {
    super.initState();
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    final score = (widget.entry.vitalityScore ?? 0).toDouble();

    _stepsDiff = _diffLabel(
      widget.entry.totalSteps,
      widget.previousEntry?.totalSteps,
    );
    _heartRateDiff = _diffLabel(
      widget.entry.heartRate,
      widget.previousEntry?.heartRate,
    );

    print('Vitality Score: ${widget.entry.vitalityScore}, ${widget.entry.totalSteps} steps ($_stepsDiff), ${widget.entry.heartRate} bpm ($_heartRateDiff), sentiment ${widget.entry.recordingAnalysis}');
    _scoreProg = Tween<double>(begin: 0, end: score).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _ringProg = Tween<double>(
      begin: 0,
      end: (score / 100),
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.35, 0.75),
      ),
    );

    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.35, 0.80),
      ),
    );

    _chartProg = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _masterCtrl.forward();
  }

  /// Percentage change of [current] vs [previous].
  /// Returns '—' when there's nothing to compare against — no previous
  /// entry, or [previous] is 0 (percentage change against zero is undefined).
  String _diffLabel(int? current, int? previous) {
    if (current == null || previous == null || previous == 0) {
      return '—';
    }
    final pct = ((current - previous) / previous * 100).round();
    if (pct == 0) return '0%';
    return pct > 0 ? '+$pct%' : '$pct%';
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          'Journal Result',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── SCORE ─────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _masterCtrl,
                builder: (_, __) => ScoreRing(
                  score: _scoreProg.value.round(),
                  progress: _ringProg.value,
                ),
              ),
            ),

            // const SizedBox(height: 20),

            // Text(
            //   'Location: ${e.locationCity ?? "Unknown"}',
            //   style: AppTextStyles.body,
            // ),

            // const SizedBox(height: 20),
            

            // ── METRICS ───────────────────────────
            SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.directions_walk,
                        value: '${e.totalSteps ?? 0}',
                        unit: 'steps',
                        label: 'Activity',
                        iconColor: AppColors.primary,
                        diffrence: _stepsDiff,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.favorite,
                        value: '${e.heartRate ?? 0}',
                        unit: 'bpm',
                        label: 'Heart Rate',
                        iconColor: AppColors.primary,
                        diffrence: _heartRateDiff,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── VOICE ─────────────────────────────
            FadeTransition(
              opacity: _cardsFade,
              child: VoiceAnalysisCard(
                emotion: e.recordingAnalysis ?? "Unknown",
                chartProgress: _chartProg,
                heights:e.recordingCurve ?? [] 
              ),
            ),

            const SizedBox(height: 12),

            // Text(
            //   'Emotion: ${e.recordingAnalysis ?? "Unknown"}',
            //   style: AppTextStyles.body,
            // ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}