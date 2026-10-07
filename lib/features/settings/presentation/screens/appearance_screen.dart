// lib/features/settings/presentation/screens/appearance_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kora/core/common/app_loader.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_text_styles.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _loading = true;

  DocumentReference get _userDoc => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final snap = await _userDoc.get();
    final data = snap.data() as Map<String, dynamic>?;
    final saved = data?['appearanceSettings']?['themeMode'] as String?;
    setState(() {
      _themeMode = _themeModeFromString(saved);
      _loading = false;
    });
  }

  Future<void> _selectThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _userDoc.set({
      'appearanceSettings': {'themeMode': _themeModeToString(mode)},
    }, SetOptions(merge: true));

    // NOTE: Selecting a mode here only saves the preference. To actually
    // switch the app's theme, hook this into whatever controls your
    // MaterialApp's `themeMode` (e.g. a ChangeNotifier/Provider/Riverpod
    // controller read at app startup and updated here).
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          'Appearance',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: AppLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.accessibility_new_outlined,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Theme',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how Kora looks. "System" follows your device\'s '
                    'display setting automatically.',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textPrimary.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        _ThemeOptionRow(
                          icon: Icons.brightness_auto_outlined,
                          label: 'System default',
                          selected: _themeMode == ThemeMode.system,
                          onTap: () => _selectThemeMode(ThemeMode.system),
                          isFirst: true,
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.textPrimary.withOpacity(0.06),
                        ),
                        _ThemeOptionRow(
                          icon: Icons.light_mode_outlined,
                          label: 'Light mode',
                          selected: _themeMode == ThemeMode.light,
                          onTap: () => _selectThemeMode(ThemeMode.light),
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.textPrimary.withOpacity(0.06),
                        ),
                        _ThemeOptionRow(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark mode',
                          selected: _themeMode == ThemeMode.dark,
                          onTap: () => _selectThemeMode(ThemeMode.dark),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _ThemeOptionRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}