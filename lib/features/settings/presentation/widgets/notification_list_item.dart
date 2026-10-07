// lib/core/common/notification_list_item.dart
import 'package:flutter/material.dart';
import 'package:kora/core/theme/app_colors.dart';
import 'package:kora/core/common/list_item.dart';
import 'package:kora/features/settings/presentation/screens/notification_list_screen.dart';

/// Settings-row entry point for notifications.
/// Tapping it opens the dedicated NotificationSettingsScreen, which is
/// where the enable toggle and reminder time actually live.
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      iconWidget: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_none,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: 'Notifications',
      subtitle: 'Manage your reminders and alerts',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
      ),
    );
  }
}