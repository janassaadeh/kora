
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/location_pill.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/widgets/pill_chip.dart';

class MetadataRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read locationCity from the bloc so the pill updates automatically
    // when GPS resolves, and again if the user edits it manually.
    return BlocBuilder<EntryBloc, EntryState>(
      buildWhen: (p, c) =>
          p.locationCity != c.locationCity ||
          p.locationLoading != c.locationLoading,
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PillChip(label: _formattedToday()),
            // PillChip(
            //   icon: Icons.add,
            //   label: 'ADD TAGS',
            //   onTap: () {},
            // ),
            LocationPill(
              currentCity: state.locationCity,
              loading: state.locationLoading,
            ),
          ],
        );
      },
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
      'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];
    final dayName = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$dayName, ${month.substring(0, 3)} ${now.day}';
  }
}
