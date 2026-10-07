
import 'package:flutter/widgets.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/reason_chip.dart';

class ReasonChipGrid extends StatelessWidget {
  final List<String> reasons;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  const ReasonChipGrid({
    required this.reasons,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pair into rows of 2
    final rows = <List<String>>[];
    for (int i = 0; i < reasons.length; i += 2) {
      rows.add(reasons.sublist(i, (i + 2).clamp(0, reasons.length)));
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: row.map((reason) {
              final isSelected = selected.contains(reason);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: row.indexOf(reason) == 0 ? 8 : 0,
                  ),
                  child: ReasonChip(
                    label: reason,
                    selected: isSelected,
                    onTap: () => onTap(reason),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
