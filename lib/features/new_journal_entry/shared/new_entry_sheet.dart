import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/di/injector.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/pages/context_step.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/pages/reasons_step.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/pages/results_step.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
import 'package:kora/features/new_journal_entry/health/presentation/pages/activity_step.dart';
import 'package:kora/features/new_journal_entry/health/presentation/pages/heart_rate_step.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/bloc/recording_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/pages/recording_step.dart';
import 'package:kora/features/new_journal_entry/shared/entities/entry_step.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_sheet_header.dart';



class NewEntrySheet extends StatelessWidget {
  final VoidCallback? onComplete;
  const NewEntrySheet({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthBloc>()..add(const HealthInitialized()),
      child: BlocProvider(
        create: (_) => sl<RecordingBloc>(),
        child: Builder(
          builder: (ctx) => BlocProvider(
            create: (_) => sl<EntryBloc>(
              param1: ctx.read<HealthBloc>(),
              param2: ctx.read<RecordingBloc>(),
            )..add(const EntryInitialized()),
            child: _NewEntrySheetBody(onComplete: onComplete),
          ),
        ),
      ),
    );
  }
}

class _NewEntrySheetBody extends StatelessWidget {
  final VoidCallback? onComplete;
  const _NewEntrySheetBody({this.onComplete});

  static const _totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EntryBloc, EntryState>(
      listenWhen: (p, c) =>
          p.draftJustSaved != c.draftJustSaved ||
          p.hasSavedDraft != c.hasSavedDraft,
      listener: (ctx, state) {
        if (state.hasSavedDraft) {
          ctx.read<EntryBloc>().add(const DraftRestoreRequested());
        }
      },
      child: BlocBuilder<EntryBloc, EntryState>(
        builder: (ctx, state) {
          return DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:AppRadius.radius
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          EntrySheetHeader(
                            currentStep: state.step.index + 1,
                            totalSteps: _totalSteps,
                            onClose: () => _onClosePressed(ctx),
                          ),
                          Expanded(child: _stepPage(state.step, ctx)),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepPage(EntryStep step, BuildContext context) {
    switch (step) {
      case EntryStep.reason:
        return const ReasonStepPage();
      case EntryStep.voice:
        return const VoiceStepPage();
      case EntryStep.context:
        return const ContextStepPage();
      case EntryStep.heartRate:
        return const HeartRateStepPage();
      case EntryStep.activity:
        return const ActivityStepPage();
      case EntryStep.results:
        return ResultsStepPage(onDone: onComplete);
    }
  }

  Future<void> _onClosePressed(BuildContext context) async {
    final entryBloc = context.read<EntryBloc>();
    final recordingBloc = context.read<RecordingBloc>();
    final state = entryBloc.state;

    if (state.step == EntryStep.results) {
      Navigator.of(context).pop();
      return;
    }

    final hasProgress = state.step != EntryStep.reason ||
        state.contextText.isNotEmpty ||
        state.selectedReasons.isNotEmpty ||
        state.reasonNote.isNotEmpty ||
        recordingBloc.state.status != RecordingStatus.idle;

    if (!hasProgress) {
      Navigator.of(context).pop();
      return;
    }

    final result = await showDialog<_CloseAction>(
      context: context,
      builder: (_) => const _SaveDraftDialog(),
    );

    switch (result) {
      case _CloseAction.saveDraft:
        entryBloc.add(const SaveDraftRequested());
        if (context.mounted) Navigator.of(context).pop();
      case _CloseAction.discard:
        entryBloc.add(const DraftDiscarded());
        if (context.mounted) Navigator.of(context).pop();
      case _CloseAction.cancel:
      case null:
        break;
    }
  }
}

enum _CloseAction { saveDraft, discard, cancel }

class _SaveDraftDialog extends StatelessWidget {
  const _SaveDraftDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius:AppRadius.radius),
      title:  Text('Save and come back later?',style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary)),
      content:  Text(
          'Your progress will be saved so you can pick up where you left off.',style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary, height: 1.4, fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_CloseAction.discard),
          child:  Text('Discard',
              style: AppTextStyles.headingSmall.copyWith(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_CloseAction.cancel),
          child:  Text('Keep editing',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),

        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_CloseAction.saveDraft),
          child: const Text('Save draft'),
        ),
      ],
    );
  }
}