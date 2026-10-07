import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'journal_reminder';
  static const _notifId = 42;

  Future<void> init() async {
    tz.initializeTimeZones();

    const tzMap = {
      'EEST': 'Asia/Beirut',
      'EET': 'Asia/Beirut',
      'AST': 'Asia/Riyadh',
      'GST': 'Asia/Dubai',
    };

    final String timeZoneName = DateTime.now().timeZoneName;
    try {
      final mapped = tzMap[timeZoneName] ?? timeZoneName;
      tz.setLocalLocation(tz.getLocation(mapped));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Checks whether the app currently has permission to schedule exact
  /// alarms, and requests it if not. On Android this opens the system
  /// "Alarms & reminders" settings screen rather than an in-app dialog —
  /// that's expected platform behavior. Returns false (rather than
  /// throwing) if permission isn't granted, so callers can fall back to
  /// an inexact schedule instead of crashing.
  Future<bool> _ensureExactAlarmPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) return true;

      final result = await Permission.scheduleExactAlarm.request();
      return result.isGranted;
    } catch (_) {
      // Platform doesn't support this permission (e.g. iOS) or the check
      // itself failed — just fall back to inexact scheduling.
      return false;
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_notifId);

    final hasExactAlarmPermission = await _ensureExactAlarmPermission();
    final scheduledTime = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      _notifId,
      'Time to journal 📝',
      'Take a moment to log how you\'re feeling today.',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Journal Reminders',
          channelDescription: 'Daily reminder to complete a journal entry',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: hasExactAlarmPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel() => _plugin.cancel(_notifId);

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}