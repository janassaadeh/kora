import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_back_button.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';

class ContextStepPage extends StatefulWidget {
  const ContextStepPage({super.key});

  @override
  State<ContextStepPage> createState() => _ContextStepPageState();
}

class _ContextStepPageState extends State<ContextStepPage> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final initial = context.read<EntryBloc>().state.contextText;
    _ctrl = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntryBloc, EntryState>(
      builder: (ctx, state) {
        final bloc = ctx.read<EntryBloc>();

        return Center(
          child: Column(
            children: [
              Text('Add more context', style: AppTextStyles.headingLarge),
              const SizedBox(height: 6),
              Text(
                'Take a moment to reflect on your day. What\'s unfolding in your mind right now?',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Text field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    borderRadius: AppRadius.radius
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Begin typing your thoughts here…',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (v) => bloc.add(ContextTextChanged(v)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),

                          Text(
                            'Private & Encrypted',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const Spacer(),

                          ValueListenableBuilder(
                            valueListenable: _ctrl,
                            builder: (_, __, ___) => Text(
                              '${_ctrl.text.length} characters',
                              style: AppTextStyles.headingSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: EntryBackButton(
                      onTap: () => bloc.add(PrevStepRequested()),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: EntryPrimaryButton(
                      label: 'Next',
                      onTap: () => bloc.add(NextStepRequested()),
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
