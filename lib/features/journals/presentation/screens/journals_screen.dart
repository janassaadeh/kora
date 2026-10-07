import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/journals/presentation/bloc/journal_bloc.dart';
import 'package:kora/features/journals/presentation/bloc/journal_event.dart';
import 'package:kora/features/journals/presentation/bloc/journal_state.dart';
import 'package:kora/features/journals/presentation/screens/results_screen.dart';
import 'package:kora/features/journals/presentation/widgets/journal_entry_tile.dart';
import 'package:intl/intl.dart';

enum _SortMode { latestFirst, oldestFirst, highScore, lowScore }

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _contentAnim;

  final _searchCtrl = TextEditingController();
  _SortMode _sort = _SortMode.latestFirst;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _contentAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    context.read<JournalBloc>().add(LoadEntries());
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(color: AppColors.card, child: const SizedBox(height: 10)),

                // ── Title ──────────────────────────────────────────────────
                FadeTransition(
                  opacity: _contentAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Text('PREVIOUS ENTRIES', style: AppTextStyles.body),
                  ),
                ),

                const SizedBox(height: 22),

                // ── Search ─────────────────────────────────────────────────
                FadeTransition(
                  opacity: _contentAnim,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.primaryDark.withOpacity(0.08),
                      hintText: 'Search by reason...',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search, color: AppColors.primary),
                      ),
                      // Clear button when there's text
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchCtrl.clear(),
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radius,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Sort chips ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _contentAnim,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _SortChip(
                          label: 'Latest first',
                          icon: Icons.arrow_downward,
                          active: _sort == _SortMode.latestFirst,
                          onTap: () => setState(() => _sort = _SortMode.latestFirst),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label: 'Oldest first',
                          icon: Icons.arrow_upward,
                          active: _sort == _SortMode.oldestFirst,
                          onTap: () => setState(() => _sort = _SortMode.oldestFirst),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label: 'High score',
                          icon: Icons.trending_up,
                          active: _sort == _SortMode.highScore,
                          onTap: () => setState(() => _sort = _SortMode.highScore),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label: 'Low score',
                          icon: Icons.trending_down,
                          active: _sort == _SortMode.lowScore,
                          onTap: () => setState(() => _sort = _SortMode.lowScore),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ── STATE HANDLING ─────────────────────────────────────────
                if (state is JournalLoading)
                  const Center(child: AppLoader()),

                if (state is JournalError)
                  Center(child: Text(state.message)),

                if (state is JournalLoaded)
                  Builder(builder: (_) {
                    final query = _searchCtrl.text.trim().toLowerCase();

                    // 1. Filter by reason
                    var filtered = state.entries.where((e) {
                      if (query.isEmpty) return true;
                      return e.reasons?.any(
                            (r) => r.toLowerCase().contains(query),
                          ) ??
                          false;
                    }).toList();

                    // 2. Sort
                    switch (_sort) {
                      case _SortMode.latestFirst:
                        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      case _SortMode.oldestFirst:
                        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      case _SortMode.highScore:
                        filtered.sort((a, b) =>
                            (b.vitalityScore ?? 0).compareTo(a.vitalityScore ?? 0));
                      case _SortMode.lowScore:
                        filtered.sort((a, b) =>
                            (a.vitalityScore ?? 0).compareTo(b.vitalityScore ?? 0));
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            query.isEmpty ? 'No entries yet.' : 'No results for "$query".',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    // For previousEntry we need the full time-ordered list
                    final byTime = List.of(state.entries)
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return Column(
                      children: List.generate(filtered.length, (i) {
                        final entry = filtered[i];
                        final timeIdx = byTime.indexWhere((e) => e.id == entry.id);
                        final previousEntry = timeIdx + 1 < byTime.length
                            ? byTime[timeIdx + 1]
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeTransition(
                            opacity: _contentAnim,
                            child: JournalEntryTile(
                              title: entry.reasons?.isNotEmpty == true
                                  ? entry.reasons!.first
                                  : 'Journal Entry',
                              date: DateFormat.yMMMd().format(entry.createdAt),
                              time: DateFormat.jm().format(entry.createdAt),
                              vitalityScore: entry.vitalityScore, // <-- pass score
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultScreen(
                                      entry: entry,
                                      previousEntry: previousEntry,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    );
                  }),

                const SizedBox(height: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Sort chip widget ──────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.primaryDark.withOpacity(0.08),
          borderRadius: AppRadius.radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.card : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.headingSmall.copyWith(
                color: active ? AppColors.card : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}