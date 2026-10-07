import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/analysis/presentation/widgets/focus_bar_chart.dart';
import 'package:kora/features/analysis/presentation/widgets/metric_card.dart';
import 'package:kora/features/analysis/presentation/widgets/score_ring.dart';
import 'package:kora/features/analysis/presentation/widgets/trend_line_chart.dart';
import 'package:kora/features/analysis/presentation/widgets/voice_analysis_card.dart';
import 'package:kora/features/journals/presentation/bloc/journal_bloc.dart';
import 'package:kora/features/journals/presentation/bloc/journal_event.dart';
import 'package:kora/features/journals/presentation/bloc/journal_state.dart';
import 'package:kora/features/new_journal_entry/entry/domain/entities/new_entry.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterCtrl;
  late Animation<double> _scoreProg;   // 0→latest score for counter
  late Animation<double> _ringProg;    // 0→latest score/100 for arc
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _chartProg;   // 0→1 bar heights
  late Animation<double> _chartAnim;

  // Tracks the score we last animated to, so the ring only re-animates
  // when the underlying data actually changes (fresh load, or a refresh
  // that brings in a new latest entry) instead of on every rebuild.
  int? _lastAnimatedScore;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _chartAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );
    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.35, 0.75, curve: Curves.easeOut)),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic)));
    _chartProg = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.50, 1.0, curve: Curves.easeOutBack)),
    );

    // Score/ring don't have a real value yet — sit flat at 0 until the
    // latest entry has loaded, then _startScoreAnimation gives them a
    // real Tween and kicks off the controller.
    _scoreProg = const AlwaysStoppedAnimation(0);
    _ringProg = const AlwaysStoppedAnimation(0);

    context.read<JournalBloc>().add(LoadEntries());
  }

  void _startScoreAnimation(int score) {
    _lastAnimatedScore = score;
    _scoreProg = Tween<double>(begin: 0, end: score.toDouble()).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _ringProg = Tween<double>(begin: 0, end: score / 100).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)),
    );
    _masterCtrl.forward(from: 0);
  }

  @override
  void dispose() { _masterCtrl.dispose(); super.dispose(); }

  /// Percentage change of [current] vs [previous]. '—' when there's
  /// nothing to compare against (no previous entry, or previous is 0).
  String _diffLabel(int? current, int? previous) {
    if (current == null || previous == null || previous == 0) return '—';
    final pct = ((current - previous) / previous * 100).round();
    if (pct == 0) return '0%';
    return pct > 0 ? '+$pct%' : '$pct%';
  }

  /// Builds the last-7-days bar-chart data plus a week-over-week change,
  /// comparing the average vitality score of the last 7 calendar days
  /// against the average of the 7 days before that.
  _WeeklyTrend _weeklyTrend(List<NewEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    // Oldest → newest, ending today.
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    double? avgScoreFor(DateTime day) {
      final onDay = entries.where((e) => dayOnly(e.createdAt) == day).toList();
      if (onDay.isEmpty) return null;
      final total = onDay.fold<int>(0, (sum, e) => sum + (e.vitalityScore ?? 0));
      return total / onDay.length;
    }

    final dailyHeights =
        days.map((d) => ((avgScoreFor(d) ?? 0) / 100).clamp(0.0, 1.0)).toList();
    final dayLabels = days.map((d) => DateFormat.E().format(d)).toList();

    bool withinDaysAgo(DateTime created, int minDaysAgo, int maxDaysAgo) {
      final diff = today.difference(dayOnly(created)).inDays;
      return diff >= minDaysAgo && diff < maxDaysAgo;
    }

    final thisWeek = entries.where((e) => withinDaysAgo(e.createdAt, 0, 7)).toList();
    final lastWeek = entries.where((e) => withinDaysAgo(e.createdAt, 7, 14)).toList();

    int avgOf(List<NewEntry> list) =>
        (list.fold<int>(0, (s, e) => s + (e.vitalityScore ?? 0)) / list.length)
            .round();

    final thisWeekAvg = thisWeek.isEmpty ? 0 : avgOf(thisWeek);

    String changeLabel = '—';
    bool isUp = true;
    if (thisWeek.isNotEmpty && lastWeek.isNotEmpty) {
      final lastWeekAvg = avgOf(lastWeek);
      if (lastWeekAvg != 0) {
        final pct = ((thisWeekAvg - lastWeekAvg) / lastWeekAvg * 100).round();
        isUp = pct >= 0;
        changeLabel = pct == 0 ? '0%' : (pct > 0 ? '+$pct%' : '$pct%');
      }
    }

    return _WeeklyTrend(
      dailyHeights: dailyHeights,
      dayLabels: dayLabels,
      average: thisWeekAvg,
      changeLabel: changeLabel,
      isUp: isUp,
    );
  }List<double> _dailyNorm(List<NewEntry> entries) {
  const emotionToScore = {
    'happy':   1.0,
    'neutral': 0.6,
    'sad':     0.3,
    'angry':   0.1,
    'fearful': 0.1,
  };
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime d(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  return List.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    final onDay = entries.where((e) => d(e.createdAt) == day).toList();
    if (onDay.isEmpty) return 0.0;
    final avg = onDay.fold<double>(
      0,
      (s, e) => s + (emotionToScore[e.recordingAnalysis?.toLowerCase()] ?? 0.5),
    ) / onDay.length;
    return avg;
  });
}
List<double> _dailyNormInt(
  List<NewEntry> entries,
  int? Function(NewEntry) pick,
  double max,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime d(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  return List.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    final onDay = entries.where((e) => d(e.createdAt) == day).toList();
    if (onDay.isEmpty) return 0.0;
    return (onDay.fold<int>(0, (s, e) => s + (pick(e) ?? 0)) / onDay.length / max)
        .clamp(0.0, 1.0);
  });
}
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        if (state is JournalLoading || state is JournalInitial) {
          return const Center(child: AppLoader());
        }
        if (state is JournalError) {
          return Center(child: Text(state.message));
        }

        final entries = (state as JournalLoaded).entries;
        if (entries.isEmpty) {
          return const Center(
            child: Text('Log an entry to see your analysis.'),
          );
        }

        final sorted = List.of(entries)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latest = sorted.first;
        final previous = sorted.length > 1 ? sorted[1] : null;
        final weekly = _weeklyTrend(sorted);

        final score = latest.vitalityScore ?? 0;
        if (_lastAnimatedScore != score) {
          _startScoreAnimation(score);
        }

        return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                // ── Score ring ───────────────────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => ScoreRing(
                      score: _scoreProg.value.round(),
                      progress: _ringProg.value,
                    ),
                  ),
                ),


                // ── Metric cards ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _cardsFade,
                  child: SlideTransition(
                    position: _cardsSlide,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            icon: Icons.directions_walk,
                            value: '${latest.totalSteps ?? 0}',
                            unit: 'steps',
                            label: 'Activity',
                            iconColor: AppColors.primary,
                            diffrence:
                                _diffLabel(latest.totalSteps, previous?.totalSteps),
                          ),
                        ),
                        const SizedBox(width: 10),
                         Expanded(
                           child: MetricCard(
                             icon: Icons.favorite_outline_rounded,
                             value: '${latest.heartRate ?? 0}',
                             unit: 'bpm',
                            label: 'Heart Rate',
                             iconColor: AppColors.primary,
                             diffrence:
                                 _diffLabel(latest.heartRate, previous?.heartRate),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Voice analysis ────────────────────────────────────────────
                FadeTransition(
                  opacity: _cardsFade,
                  child: VoiceAnalysisCard(
                    emotion: latest.recordingAnalysis ?? 'Unknown',
                    chartProgress: _chartProg,
                    heights: latest.recordingCurve ?? [],
                  ),
                ),
                const SizedBox(height: 28),
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius:AppRadius.radius,
    boxShadow: [BoxShadow(
      color: AppColors.primaryDark.withOpacity(0.3),
      blurRadius: 50, offset: const Offset(20, 20),
    )],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Trend Graphs', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
      const SizedBox(height: 4),
      Text('Voice Mood · Heart Rate · Activity', style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 16),
     TrendLineChart(
  animation: _chartAnim,
  moodValues: _dailyNorm(sorted),
  heartRateValues: _dailyNormInt(sorted, (e) => e.heartRate, 200),
  activityValues: _dailyNormInt(sorted, (e) => e.totalSteps, 15000),
  dayLabels: weekly.dayLabels,
),
    ],
  ),
),
      const SizedBox(height: 28),

                 Container(
                  height: 300,
            padding: const EdgeInsets.fromLTRB(13.5, 20, 0, 0),
                        decoration: BoxDecoration(
              color: AppColors.card,
                          borderRadius: AppRadius.radius,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.3),
                              blurRadius: 50,
                              offset: const Offset(20, 20),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Weekly Trends',
                                              style: AppTextStyles.headingMedium.copyWith(
                                                  color: AppColors.primary)),
                                                   const SizedBox(height: 5),
                                  Text('Last 7 days average: ${weekly.average}',
                                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),

                                        ],
                                      ),
                                      Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FadeTransition(
                                  opacity: _chartAnim,
                                  child: Text(
                                    weekly.changeLabel,
                                    style: AppTextStyles.headingLarge.copyWith(
                                        color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  weekly.changeLabel == '—'
                                      ? 'LAST WEEK'
                                      : weekly.isUp
                                          ? '↑ LAST WEEK'
                                          : '↓ LAST WEEK',
                                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                                    ],
                                  ),
                                 const SizedBox(height: 14),
                                  FocusBarChart(
                                    animation: _chartAnim,
                                    values: weekly.dailyHeights,
                                    dayLabels: weekly.dayLabels,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                          ],
                        ),
                      ),
              ],
            ),
        );
      },
    );
  }
}

class _WeeklyTrend {
  final List<double> dailyHeights; // 0..1, oldest → newest, today last
  final List<String> dayLabels;    // matches dailyHeights, e.g. 'Mon'
  final int average;               // average vitality score, last 7 days
  final String changeLabel;        // '+12%' / '-4%' / '0%' / '—'
  final bool isUp;

  _WeeklyTrend({
    required this.dailyHeights,
    required this.dayLabels,
    required this.average,
    required this.changeLabel,
    required this.isUp,
  });
}