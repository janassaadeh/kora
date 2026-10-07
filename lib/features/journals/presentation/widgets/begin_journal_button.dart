import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/core/di/injector.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/draft_usecases.dart';
import 'package:kora/features/new_journal_entry/shared/new_entry_sheet.dart';

class BeginJournalButton extends StatelessWidget {
  const BeginJournalButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openNewEntry(context),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Begin Journal Entry',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openNewEntry(BuildContext context) async {
  final hasDraft = await sl<HasDraftUseCase>()();

  if (!context.mounted) return;

  if (hasDraft) {
    final action = await showDialog<_DraftAction>(
      context: context,
      builder: (_) => const _DraftPromptDialog(),
    );
    if (action == null) return;
    if (action == _DraftAction.discard) await sl<ClearDraftUseCase>()();
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const NewEntrySheet(),
  );
}

enum _DraftAction { continueDraft, discard }

class _DraftPromptDialog extends StatelessWidget {
  const _DraftPromptDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius:AppRadius.radius),
      title:  Text('Continue where you left off?',style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
      content:  Text('You have an unfinished journal entry.',style: AppTextStyles.body.copyWith(fontSize: 14,color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_DraftAction.discard),
          child:  Text('Start fresh',
              style: AppTextStyles.body.copyWith(fontSize:14,color: Colors.redAccent)),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_DraftAction.continueDraft),
          child:  Text('Continue', style: AppTextStyles.body.copyWith(fontSize:14,color: AppColors.card)),
        ),
      ],
    );
  }
}