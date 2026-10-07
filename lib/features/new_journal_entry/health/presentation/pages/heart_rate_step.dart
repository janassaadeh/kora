import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
import 'package:kora/features/new_journal_entry/health/presentation/widgets/dotted_scanning_border.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_back_button.dart';
import 'package:kora/features/new_journal_entry/shared/widgets/entry_primary_button.dart';
import 'package:kora/features/new_journal_entry/health/presentation/widgets/pulsing_ring.dart';
import 'package:kora/features/new_journal_entry/health/presentation/widgets/scanning_badge.dart';

class HeartRateStepPage extends StatefulWidget {
  const HeartRateStepPage({super.key});

  @override
  State<HeartRateStepPage> createState() => _HeartRateStepPageState();
}

class _HeartRateStepPageState extends State<HeartRateStepPage> {
  final _controller = TextEditingController();
  int? _manualBpm;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (ctx, state) {
        final healthBloc = ctx.read<HealthBloc>();
        final entryBloc = ctx.read<EntryBloc>();

        if (state.heartRateStatus == HeartRateScanStatus.failed &&
            state.heartRate == null) {
          return _buildFailedState(ctx, healthBloc, entryBloc);
        }
        return _buildScanningState(ctx, state, healthBloc, entryBloc);
      },
    );
  }

  Widget _buildScanningState(BuildContext ctx, HealthState state,
      HealthBloc healthBloc, EntryBloc entryBloc) {
    final scanning =
        state.heartRateStatus == HeartRateScanStatus.scanning;

    return Center(
      child: Column(
        children: [
          Text('Measuring Heart Rate', style: AppTextStyles.headingLarge),
          const SizedBox(height: 6),
          Text(
            'Stay still while we sync data from your connected smartwatch.',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: AppRadius.radius,
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                if (scanning) const ScanningBadge(label: 'Reading from watch'),
                const SizedBox(height: 32),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PulsingRing(scanning: scanning),
                      DottedScanningBorder(scanning: scanning, size: 224),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.accent, width: 2),
                        ),
                        child: Icon(Icons.watch_outlined,
                            size: 60, color: AppColors.primary),
                      ),
                      if (state.heartRate != null)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.radius,
                            ),
                            child: Text(
                              '${state.heartRate} bpm',
                              style: AppTextStyles.headingSmall
                                  .copyWith(color: AppColors.card),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
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
                  onTap: state.heartRate != null
                      ? () => entryBloc.add(const NextStepRequested())
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(
      BuildContext ctx, HealthBloc healthBloc, EntryBloc entryBloc) {
    return Center(
      child: Column(
        children: [
          Text('Measuring Heart Rate', style: AppTextStyles.headingLarge),
          const SizedBox(height: 6),
          Text(
            'No data found from your smartwatch.',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: AppRadius.radius,
            ),
            child: Column(
              children: [
                Icon(Icons.watch_off_outlined,
                    size: 56, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text("Couldn't read heart rate",
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Enter it manually or skip this step.',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary, fontSize: 12),
                
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 40,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingSmall,
                        decoration: InputDecoration(
                          hintText: '72',
                          hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radius,
                          ),
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          setState(() {
                            _manualBpm = (parsed != null &&
                                    parsed >= 30 &&
                                    parsed <= 220)
                                ? parsed
                                : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('bpm',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Normal resting range: 60–100 bpm',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: EntryPrimaryButton(
                    label: 'Confirm',
                    onTap: _manualBpm != null
                        ? () => healthBloc
                            .add(HeartRateManuallyEntered(_manualBpm!))
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() => _manualBpm = null);
                    healthBloc.add(const HeartRateScanRequested());
                  },
                  child: Text('Try again',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.primary,fontSize: 12)),
                ),
              ],
            ),
          ),
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
                  label: 'Skip',
                  onTap: () {
                    healthBloc.add(const HeartRateSkipped());
                    entryBloc.add(const NextStepRequested());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}