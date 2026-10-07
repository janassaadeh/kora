import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/di/injector.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:kora/features/exercises/presentation/screens/exercises_screen.dart';
import 'package:kora/features/journals/presentation/widgets/begin_journal_button.dart';
import 'package:kora/features/main_shell/presentation/widgets/app_nav_bar.dart';
import 'package:kora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kora/features/profile/presentation/bloc/profile_event.dart';
import 'package:kora/features/profile/presentation/bloc/profile_state.dart';
import 'package:kora/features/profile/presentation/screens/profile_screen.dart';
import 'package:kora/features/settings/presentation/screens/settings_screen.dart';
import 'package:kora/features/journals/presentation/screens/journals_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _navIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  print("FAB pressed");
                  await openNewEntry(context);
                } catch (e, st) {
                  print("ERROR: $e");
                  print(st);
                }
              },
              shape: const CircleBorder(),
              backgroundColor: AppColors.primary,
              child: Icon(Icons.edit_note, color: AppColors.card, size: 22),
            )
          : null,

      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Center(
          child: Text(
            'Kora AI',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      leading: GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ProfileScreen(),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: BlocSelector<ProfileBloc, ProfileState, String?>(
      selector: (state) =>
          state is ProfileLoaded ? state.user.photoUrl : null,
      builder: (context, photoUrl) {
  ImageProvider? image;
  if (photoUrl != null) {
    try {
      image = MemoryImage(base64Decode(photoUrl));
    } catch (_) {
      image = null;
    }
  }
  return CircleAvatar(
    radius: 14,
    backgroundColor: AppColors.accent,
    backgroundImage: image,
    child: image == null
        ? const Icon(Icons.person, color: AppColors.primary, size: 18)
        : null,
  );
},
    ),
  ),
),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          // ── Tab 0: Analysis ────────────────────────────────────────────────
          // Generates a unique key when active to replay intro animations.
          AnalysisScreen(key: _navIndex == 0 ? UniqueKey() : null),

          // ── Tab 1: Trends ──────────────────────────────────────────────────
          JournalsScreen(key: _navIndex == 1 ? UniqueKey() : null),

          // ── Tab 2: Breathe ─────────────────────────────────────────────────
          ExercisesScreen(key: _navIndex == 2 ? UniqueKey() : null),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
