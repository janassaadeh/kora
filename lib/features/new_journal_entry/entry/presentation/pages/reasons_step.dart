import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/meta_data_row.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/note_field.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/reason_chip_grid.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_back_button.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';
import 'package:kora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kora/features/profile/presentation/bloc/profile_state.dart';

class ReasonStepPage extends StatefulWidget {
  const ReasonStepPage({super.key});

  @override
  State<ReasonStepPage> createState() => _ReasonStepPageState();
}

class _ReasonStepPageState extends State<ReasonStepPage> {
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();

  static const _writingReasons = [
    'Stress Relief',
    'Gratitude',
    'Anxiety',
    'Reflecting',
    'Goal Tracking',
    'Just Venting',
  ];

  @override
  void initState() {
    super.initState();
    // Seed from whatever the bloc currently has (covers the case where a
    // draft was already restored before this page first builds).
    _noteController.text = context.read<EntryBloc>().state.reasonNote;
    _noteController.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    context.read<EntryBloc>().add(ReasonNoteChanged(_noteController.text));
  }

  @override
  void dispose() {
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _toggleReason(String reason) {
    final bloc = context.read<EntryBloc>();
    final updated = Set<String>.from(bloc.state.selectedReasons);
    if (updated.contains(reason)) {
      updated.remove(reason);
    } else {
      updated.add(reason);
    }
    bloc.add(WritingReasonsChanged(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntryBloc, EntryState>(
      // Keep the note field in sync if the draft is restored asynchronously
      // after this page has already built.
      listenWhen: (p, c) => p.reasonNote != c.reasonNote,
      listener: (ctx, state) {
        if (_noteController.text != state.reasonNote) {
          _noteController.text = state.reasonNote;
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and metadata chips
              MetadataRow(),
              const SizedBox(height: 24),

              // Greeting
              BlocSelector<ProfileBloc, ProfileState, String>(
                selector: (state) {
  if (state is! ProfileLoaded) return '';
  final user = state.user;
  return user.displayName ?? user.email;
},
                builder: (context, displayName) => Text(
                  displayName.isNotEmpty ? 'Hello, $displayName' : 'Hello',
                  style: AppTextStyles.headingLarge,
                ),
              ),
              const SizedBox(height: 4),
              Text("What's on your mind today?", style: AppTextStyles.body),
              const SizedBox(height: 28),

              // Writing reasons section
              Text(
                'I AM WRITING FOR...',
                style: GoogleFonts.notoSerif(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              ReasonChipGrid(
                reasons: _writingReasons,
                selected: state.selectedReasons,
                onTap: _toggleReason,
              ),
              const SizedBox(height: 28),

              // Quick note section
              Text(
                'ADD A QUICK NOTE (OPTIONAL)',
                style: GoogleFonts.notoSerif(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              NoteField(controller: _noteController, focusNode: _noteFocusNode),

              const Spacer(),

              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: EntryPrimaryButton(
                      label: 'Next',
                      onTap: () =>
                          context.read<EntryBloc>().add(NextStepRequested()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
