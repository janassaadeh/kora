import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/animated_wave_form.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_back_button.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/record_controls.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/recording_badge.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/widgets/timer_display.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/bloc/recording_bloc.dart';

class VoiceStepPage extends StatefulWidget {
  const VoiceStepPage({super.key});

  @override
  State<VoiceStepPage> createState() => _VoiceStepPageState();
}

class _VoiceStepPageState extends State<VoiceStepPage>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final recordingBloc = context.read<RecordingBloc>();
        final entryBloc = context.read<EntryBloc>();

        final status = state.status;
        final isIdle = status == RecordingStatus.idle;
        final isDone = status == RecordingStatus.done;
        final isActive = status == RecordingStatus.recording ||
            status == RecordingStatus.paused;
        final isPaused = status == RecordingStatus.paused;
        final samples = state.amplitudeSamples.isEmpty
            ? List.filled(15, 0.0)
            : state.amplitudeSamples;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text('Speak your mind', style: AppTextStyles.headingLarge),
            const SizedBox(height: 12),
            Text(
              'Take all the time you need to express your thoughts.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 351,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: isIdle
                    ? _IdleCard(
                        key: const ValueKey('idle'),
                        onStart: () =>
                            recordingBloc.add(const RecordingStarted()),
                      )
                    : isDone
                        ? _DoneCard(
                            key: const ValueKey('done'),
                            duration:
                                _formatDuration(state.duration),
                            onRetry: () =>
                                recordingBloc.add(const RecordingCancelled()),
                          )
                        : _RecordingCard(
                            key: const ValueKey('recording'),
                            dotCtrl: _dotCtrl,
                            waveCtrl: _waveCtrl,
                            isPaused: isPaused,
                            timeLabel: _formatDuration(state.duration),
                            samples: samples,
                          ),
              ),
            ),

            const SizedBox(height: 28),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: isActive
                  ? RecordControls(
                      key: const ValueKey('rec-controls'),
                      isPaused: isPaused,
                      onToggle: () => recordingBloc.add(
                        isPaused
                            ? const RecordingResumed()
                            : const RecordingPaused(),
                      ),
                      cancelFct: () =>
                          recordingBloc.add(const RecordingCancelled()),
                      finishFct: () =>
                          recordingBloc.add(const RecordingFinished()),
                    )
                  : _NavButtons(
                      key: const ValueKey('nav-buttons'),
                      canGoBack:
                          entryBloc.state.step.index > 0,
                      onBack: () =>
                          entryBloc.add(const PrevStepRequested()),
                      onNext: () =>
                          entryBloc.add(const NextStepRequested()),
                      nextEnabled: isDone,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Idle card ─────────────────────────────────────────────────────────────────

class _IdleCard extends StatelessWidget {
  final VoidCallback onStart;
  const _IdleCard({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.08),
        borderRadius: AppRadius.radius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none_rounded,
            size: 48,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready when you are',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text('Start Recording'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radius,
              ),
              textStyle: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active recording card ─────────────────────────────────────────────────────

class _RecordingCard extends StatelessWidget {
  final AnimationController dotCtrl;
  final AnimationController waveCtrl;
  final bool isPaused;
  final String timeLabel;
  final List<double> samples;

  const _RecordingCard({
    super.key,
    required this.dotCtrl,
    required this.waveCtrl,
    required this.isPaused,
    required this.timeLabel,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.08),
        borderRadius:AppRadius.radius,
      ),
      child: Column(
        children: [
          RecordingBadge(dotCtrl: dotCtrl),
          const SizedBox(height: 18),
          Text(
            isPaused
                ? 'Recording paused'
                : 'Listening to your thoughts...',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 25),
          TimerDisplay(timeLabel: timeLabel),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedWaveform(
              controller: waveCtrl,
              barHeights: samples,
              isActive: !isPaused,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Done card ─────────────────────────────────────────────────────────────────

class _DoneCard extends StatelessWidget {
  final String duration;
  final VoidCallback onRetry;

  const _DoneCard({
    super.key,
    required this.duration,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.4),
        borderRadius: AppRadius.radius,
        border:
            Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Recording saved',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            duration,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Record again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              // side: BorderSide(color: AppColors.primaryDark),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav buttons ───────────────────────────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  final bool canGoBack;
  final bool nextEnabled;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavButtons({
    super.key,
    required this.canGoBack,
    required this.nextEnabled,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        canGoBack
            ? SizedBox(
                width: 120,
                child: EntryBackButton(onTap: onBack),
              )
            : const SizedBox(width: 80),
        SizedBox(
          width: 120,
          child: EntryPrimaryButton(
            label: 'Next',
            onTap: nextEnabled ? onNext : null,
          ),
        ),
      ],
    );
  }
}