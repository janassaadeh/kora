import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/analysis/presentation/widgets/score_ring.dart';
import 'package:kora/features/journals/presentation/screens/results_screen.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';

class ResultsStepPage extends StatefulWidget {
  final VoidCallback? onDone;
  const ResultsStepPage({super.key, this.onDone});

  @override
  State<ResultsStepPage> createState() => _ResultsStepPageState();
}

class _ResultsStepPageState extends State<ResultsStepPage>
    with TickerProviderStateMixin {
  late AnimationController _masterCtrl;
  late Animation<double> _scoreProg;
  late Animation<double> _ringProg;
  late Animation<double> _cardsFade;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreProg = Tween<double>(begin: 0, end: 0).animate(_masterCtrl);
    _ringProg = Tween<double>(begin: 0, end: 0).animate(_masterCtrl);
    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Score may already be in state when this page first mounts
    // (e.g. _computeVitality finished before the route transition completed).
    if (!_animationStarted) {
      final score = context.read<EntryBloc>().state.vitalityScore;
      if (score != null) _startAnimations(score);
    }
  }

  void _startAnimations(int score) {
    if (_animationStarted) return;
    _animationStarted = true;
    final target = score.toDouble();
    _scoreProg = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _ringProg = Tween<double>(begin: 0, end: target / 100).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _masterCtrl.forward();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntryBloc, EntryState>(
      // Catches the case where score arrives after the page mounts.
      listenWhen: (p, c) => !_animationStarted && c.vitalityScore != null,
      listener: (_, state) => _startAnimations(state.vitalityScore!),
      builder: (ctx, state) {
        final bloc = ctx.read<EntryBloc>();

        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(
                  'Your Results',
                   style: AppTextStyles.headingLarge),

                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    borderRadius: AppRadius.radius
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: AnimatedBuilder(
                          animation: _masterCtrl,
                          builder: (_, __) => ScoreRing(
                            score: _scoreProg.value.round(),
                            progress: _ringProg.value,
                          ),
                        ),
                      ),

                      // const SizedBox(height: 30),
                      // FadeTransition(
                      //   opacity: _cardsFade,
                      //   child: Text(
                      //     state.vitalityDescription,
                      //     textAlign: TextAlign.center,
                      //     style: AppTextStyles.headingSmall
                      //         .copyWith(color: AppColors.textSecondary),
                      //   ),
                      // ),
                      // const SizedBox(height: 35),
                    ],
                  ),
                ),
                FadeTransition(
                  opacity: _cardsFade,
                  child: Builder(
                    builder: (context) {
                      final recs = _getRecommendations(
                        heartRate: state.healthSnapshot?.heartRate,
                        totalSteps:
                            state.healthSnapshot?.activityData?.totalSteps,
                        emotion: state.recordingSnapshot?.detectedEmotion,
                        vitalityScore: state.vitalityScore,
                      );
                      if (recs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Recommendations',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...recs.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: AppRadius.radius,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryDark.withOpacity(
                                        0.15,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: AppRadius.radius
                                      ),
                                      child: Icon(
                                        r.icon,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.title,
                                            style: AppTextStyles.headingSmall
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r.body,
                                            style: AppTextStyles.headingSmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 25),
                EntryPrimaryButton(
                  label: 'See Full Results',
                  loading: state.saving,
                  onTap: () {
                    final entry = context
                        .read<EntryBloc>()
                        .state
                        .lastSavedEntry;

                    debugPrint('ENTRY = $entry');

                    if (entry == null) {
                      debugPrint('ENTRY IS NULL');
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(entry: entry),
                      ),
                    );
                  },
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Recommendation {
  final IconData icon;
  final String title;
  final String body;
  const _Recommendation({
    required this.icon,
    required this.title,
    required this.body,
  });
}

List<_Recommendation> _getRecommendations({
  required int? heartRate,
  required int? totalSteps,
  required String? emotion,
  required int? vitalityScore,
}) {
  final recs = <_Recommendation>[];

  // Low activity
  if (totalSteps != null && totalSteps < 3000) {
    recs.add(
      const _Recommendation(
        icon: Icons.directions_walk_rounded,
        title: 'Take a short walk',
        body:
            'Your activity is low today. Even 10 minutes outside can lift your energy and mood.',
      ),
    );
  }

  // Elevated heart rate
  if (heartRate != null && heartRate > 85) {
    recs.add(
      const _Recommendation(
        icon: Icons.air_rounded,
        title: 'Try a breathing exercise',
        body:
            'Your heart rate is elevated. Try 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s.',
      ),
    );
  }

  // Negative emotion
  if (emotion != null &&
      ['sad', 'angry', 'fearful'].contains(emotion.toLowerCase())) {
    recs.add(
      const _Recommendation(
        icon: Icons.edit_note_rounded,
        title: 'Reflect in your journal',
        body:
            'Your voice suggests some stress. Writing down your thoughts can help process your feelings.',
      ),
    );
  }

  // Low vitality catch-all
  if (recs.isEmpty && vitalityScore != null && vitalityScore < 50) {
    recs.add(
      const _Recommendation(
        icon: Icons.self_improvement_rounded,
        title: 'Take a mindful break',
        body:
            'Your vitality score is low. A 5-minute pause to breathe and reset can help.',
      ),
    );
  }

  return recs;
}
