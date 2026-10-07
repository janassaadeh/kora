import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_back_button.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';
import 'package:kora/features/new_journal_entry/health/presentation/widgets/stat_tile.dart';

class ActivityStepPage extends StatelessWidget {
  const ActivityStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (ctx, state) {
        final entryBloc = ctx.read<EntryBloc>();
        final data = state.activityData;

        return Center(
          child: Column(
            children: [
              Text('Your Activity', style: AppTextStyles.headingLarge),
              const SizedBox(height: 4),
              Text(
                'Movement summary for today',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (data == null)
                const Expanded(
                  child: Center(
                    child: AppLoader(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 50),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    borderRadius: AppRadius.radius,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'TOTAL STEPS',
                          style: GoogleFonts.notoSerif(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatSteps(data.totalSteps),
                          style: GoogleFonts.notoSerif(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'steps',
                          style: GoogleFonts.notoSerif(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.stepProgress,
                            backgroundColor: AppColors.border,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Goal: ${_formatSteps(data.stepGoal)}',
                              style: GoogleFonts.notoSerif(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              '${(data.stepProgress * 100).toInt()}%',
                              style: GoogleFonts.notoSerif(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: StatTile(
                                label: 'Calories',
                                value: '${data.calories}',
                                unit: 'Cal',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                label: 'Activity',
                                value: '${data.activityMinutes}',
                                unit: 'minutes',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: EntryBackButton(
                        onTap: () =>
                            entryBloc.add(const PrevStepRequested())),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: EntryPrimaryButton(
                      label: 'Next',
                      onTap: () =>
                          entryBloc.add(const NextStepRequested()),
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

  String _formatSteps(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}