import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:android_intent_plus/android_intent.dart';

// ── Dev flags ─────────────────────────────────────────────────────────────────
const bool kMockHeartRate = false;
const bool kMockSteps = false;
const bool kMockCalories = false;
const bool kMockActivityMin = false;

class HealthLocalDataSource {
  final Health _health = Health();
  final _rng = Random();

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    // FIX: EXERCISE_TIME removed — confirmed via device logs that this type
    // does not exist on Health Connect at all ("Not available on platform
    // HealthPlatformType.googleHealthConnect"). It's a Google Fit-only
    // concept ("move minutes"). Health Connect only exposes exercise data
    // as WORKOUT sessions, so that's the sole source for activity minutes
    // on this platform — not a fallback, the only option.
  ];

  // ── Permissions ────────────────────────────────────────────────────────────
  // FIX: configure() must NOT be called lazily here (e.g. inside a button
  // tap handler). Android's ActivityResultLauncher — which the health
  // plugin needs to show the Health Connect permission dialog — can only be
  // registered while the Activity is still in an early lifecycle state
  // (before STARTED). Calling configure() on-demand at request time is too
  // late, and produces exactly the "Permission launcher not found" error.
  // Call `HealthLocalDataSource.configureEarly()` once at app startup
  // instead (see bottom of this file / main.dart usage note).

  static bool _configured = false;

  /// Call this ONCE, as early as possible — ideally in main() right after
  /// WidgetsFlutterBinding.ensureInitialized(), before runApp(). This is
  /// what actually registers the Android permission launcher in time.
  static Future<void> configureEarly() async {
    if (_configured) return;
    try {
      await Health().configure();
      _configured = true;
    } catch (e) {
      debugPrint('Health configure error: $e');
    }
  }

  Future<bool> hasPermissions() async {
    final permissions = _types.map((_) => HealthDataAccess.READ).toList();
    final granted = await _health.hasPermissions(_types, permissions: permissions);
    return granted ?? false;
  }

  Future<bool> requestPermissions() async {
    if (!_configured) {
      debugPrint('WARNING: Health.configure() was not called at app startup — '
          'permission launcher registration may fail. Call '
          'HealthLocalDataSource.configureEarly() in main() before runApp().');
    }

    final permissions = _types.map((_) => HealthDataAccess.READ).toList();

    try {
      final granted = await _health.requestAuthorization(_types, permissions: permissions);
      if (!granted) {
        debugPrint('Health Connect: permission request returned false.');
      }
      return granted;
    } catch (e) {
      debugPrint('Health permission error: $e');
      return false;
    }
  }

  /// FIX (was commented out / unused): deep-links straight into Health
  /// Connect's app-permissions screen for this app, so the user doesn't have
  /// to hunt through Settings manually. Call this from the UI as a fallback
  /// button ("Open Health Connect Settings") whenever hasPermissions() is
  /// false and requestPermissions() didn't result in a granted state.
  Future<void> openHealthConnectSettings() async {
    try {
      final intent = AndroidIntent(
        action: 'android.health.connect.action.HEALTH_HOME_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      debugPrint('Could not open Health Connect settings directly, '
          'falling back to app listing: $e');
      final fallback = AndroidIntent(
        action: 'android.intent.action.VIEW',
        package: 'com.google.android.apps.healthdata',
      );
      await fallback.launch();
    }
  }

  // ── Steps ──────────────────────────────────────────────────────────────────

  Future<int?> fetchStepsToday() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      if (steps != null && steps > 0) return steps;
      return null;
    } catch (e) {
      debugPrint('Steps error: $e');
      return null;
    }
  }

  // ── Heart rate ─────────────────────────────────────────────────────────────

  Future<int?> fetchLatestHeartRate() async {
    if (kMockHeartRate) return _mockHeartRate();
    try {
      final now = DateTime.now();
      final since = now.subtract(const Duration(hours: 24));
      final samples = await _health.getHealthDataFromTypes(
        startTime: since,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );
      if (samples.isNotEmpty) {
        samples.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
        final v = samples.first.value;
        if (v is NumericHealthValue) return v.numericValue.round();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Steps-derived estimates ─────────────────────────────────────────────
  // Health Connect only reliably has continuous background data for STEPS.
  // ACTIVE_ENERGY_BURNED and WORKOUT are frequently empty unless a source
  // app explicitly logs a tracked session. Since steps are always available,
  // use them to derive consistent calorie/activity-minute estimates as a
  // fallback — standard walking heuristics, not clinically precise, but
  // good enough for a wellness-trend signal and always populated.
  //
  // ~0.04 kcal per step (average across step length/pace/body weight)
  // ~100-110 steps per minute at a moderate walking cadence
  static const double _kcalPerStep = 0.04;
  static const double _stepsPerMinute = 105.0;

  int _estimateCaloriesFromSteps(int steps) => (steps * _kcalPerStep).round();
  int _estimateActivityMinutesFromSteps(int steps) =>
      (steps / _stepsPerMinute).round();

  // ── Active calories burned today ───────────────────────────────────────────
  // FIX: prefer real Health Connect data when present (ACTIVE_ENERGY_BURNED
  // or WORKOUT), but fall back to a steps-derived estimate when both are
  // empty — background activity doesn't reliably populate either, but steps
  // (from fetchStepsToday) are always tracked.

  Future<int?> fetchCaloriesToday({int? knownSteps}) async {
    if (kMockCalories) return _mockCalories();
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final samples = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      debugPrint('Calories: got ${samples.length} ACTIVE_ENERGY_BURNED samples');

      double total = 0;
      for (final s in samples) {
        final v = s.value;
        if (v is NumericHealthValue) total += v.numericValue;
      }

      final workouts = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.WORKOUT],
      );
      for (final s in workouts) {
        final v = s.value;
        if (v is WorkoutHealthValue) total += v.totalEnergyBurned ?? 0;
      }

      if (total > 0) return total.round();

      // Fallback: derive from steps (fetch fresh if not passed in)
      final steps = knownSteps ?? await fetchStepsToday() ?? 0;
      return steps > 0 ? _estimateCaloriesFromSteps(steps) : null;
    } catch (e) {
      debugPrint('Calories error: $e');
      final steps = knownSteps ?? await fetchStepsToday() ?? 0;
      return steps > 0 ? _estimateCaloriesFromSteps(steps) : null;
    }
  }

  // ── Active/exercise minutes today ─────────────────────────────────────────
  // FIX: same pattern — prefer real WORKOUT session data, fall back to a
  // steps-derived estimate since EXERCISE_TIME doesn't exist on Health
  // Connect and WORKOUT is frequently empty for background-only activity.

  Future<int?> fetchActivityMinutesToday({int? knownSteps}) async {
    if (kMockActivityMin) return _mockActivityMinutes();
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final workouts = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.WORKOUT],
      );
      debugPrint('Activity minutes: got ${workouts.length} WORKOUT samples');

      final workoutMinutes = workouts.fold<int>(0, (sum, s) {
        return sum + s.dateTo.difference(s.dateFrom).inMinutes;
      });

      if (workoutMinutes > 0) return workoutMinutes;

      // Fallback: derive from steps
      final steps = knownSteps ?? await fetchStepsToday() ?? 0;
      return steps > 0 ? _estimateActivityMinutesFromSteps(steps) : null;
    } catch (e) {
      debugPrint('Activity minutes error: $e');
      final steps = knownSteps ?? await fetchStepsToday() ?? 0;
      return steps > 0 ? _estimateActivityMinutesFromSteps(steps) : null;
    }
  }

  // ── Combined fetch (used by the bloc) ─────────────────────────────────────

  Future<({int steps, int? heartRate, int calories, int activityMinutes})>
      fetchAll() async {
    final steps = await fetchStepsToday() ?? 0;
    final results = await Future.wait([
      fetchLatestHeartRate(),
      fetchCaloriesToday(knownSteps: steps),
      fetchActivityMinutesToday(knownSteps: steps),
    ]);
    return (
      steps: steps,
      heartRate: results[0] as int?,
      calories: (results[1] as int?) ?? 0,
      activityMinutes: (results[2] as int?) ?? 0,
    );
  }

  // ── Mock helpers ───────────────────────────────────────────────────────────

  int _mockSteps() => 3000 + _rng.nextInt(9000);
  int _mockHeartRate() => 62 + _rng.nextInt(37);
  int _mockCalories() => 150 + _rng.nextInt(400);
  int _mockActivityMinutes() => 10 + _rng.nextInt(50);
}