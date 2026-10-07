// lib/features/settings/presentation/screens/notification_settings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/theme/app_radius.dart';
import 'package:kora/core/theme/app_text_styles.dart';
import 'package:kora/features/settings/service/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0); // default 8:00 PM
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
    if (data != null && data['notificationSettings'] != null) {
      final s = data['notificationSettings'] as Map<String, dynamic>;
      setState(() {
        _enabled = s['enabled'] as bool? ?? false;
        _time = TimeOfDay(
          hour: s['hour'] as int? ?? 20,
          minute: s['minute'] as int? ?? 0,
        );
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _saveToFirestore() async {
    await _userDoc.set({
      'notificationSettings': {
        'enabled': _enabled,
        'hour': _time.hour,
        'minute': _time.minute,
      },
    }, SetOptions(merge: true));
  }

  Future<void> _onToggle(bool value) async {
    setState(() => _enabled = value);
    if (value) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: _time.hour,
        minute: _time.minute,
      );
    } else {
      await NotificationService.instance.cancel();
    }
    await _saveToFirestore();
  }

  Future<void> _pickTime() async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimeSlotSheet(initialTime: _time),
    );
    if (picked == null) return;
    setState(() => _time = picked);
    if (_enabled) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
    await _saveToFirestore();
  }

  String get _timeLabel => _time.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          'Notifications',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Daily reminders',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll send you a single gentle nudge each day at a '
                    'time you choose, so it\'s easier to stay consistent. '
                    'You can turn this off at any time.',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Settings card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withOpacity(0.03),
                      borderRadius: AppRadius.radius,
                      // border: Border.all(
                      //   color: AppColors.textPrimary.withOpacity(0.06),
                      // ),
                    ),
                    child: Column(
                      children: [
                        // Enable toggle row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Enable reminders',
                                  style: AppTextStyles.headingSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _enabled,
                                onChanged: _onToggle,
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        if (_enabled) ...[
                          // Divider(
                          //   height: 1,
                          //   color: AppColors.textPrimary.withOpacity(0.06),
                          // ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickTime,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Reminder time',
                                        style: AppTextStyles.headingSmall
                                            .copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      _timeLabel,
                                      style: AppTextStyles.headingSmall
                                          .copyWith(
                                            color: AppColors.primary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

/// A simple bottom-sheet list of time slots (30-minute increments),
/// styled to match the app rather than the default Material dial picker.
class _TimeSlotSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const _TimeSlotSheet({required this.initialTime});

  @override
  State<_TimeSlotSheet> createState() => _TimeSlotSheetState();
}

class _TimeSlotSheetState extends State<_TimeSlotSheet> {
  late final List<TimeOfDay> _slots;
  late final ScrollController _scrollController;
  late TimeOfDay _selected;

  static const double _rowHeight = 52;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTime;
    _slots = List.generate(48, (i) {
      final totalMinutes = i * 30;
      return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
    });

    final selectedIndex = _slots.indexWhere(
      (t) => t.hour == _selected.hour && t.minute == _selected.minute,
    );
    final initialOffset =
        (selectedIndex < 0 ? 0 : selectedIndex) * _rowHeight - _rowHeight * 2;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset.clamp(0, double.infinity),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder time',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Divider(height: 1, color: AppColors.textPrimary.withOpacity(0.06)),
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final isSelected =
                      slot.hour == _selected.hour &&
                      slot.minute == _selected.minute;

                  return SizedBox(
                    height: _rowHeight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  slot.format(context),
                                  style: AppTextStyles.headingSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12 + bottomInset),
          ],
        ),
      ),
    );
  }
}