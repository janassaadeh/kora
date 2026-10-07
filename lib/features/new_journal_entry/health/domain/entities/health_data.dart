class HealthData {
  final int heartRate;
  final int totalSteps;
  final int calories;
  final int activityMinutes;
  final int stepGoal;

  const HealthData({
    required this.heartRate,
    required this.totalSteps,
    required this.calories,
    required this.activityMinutes,
    required this.stepGoal,
  });

  double get stepProgress => (totalSteps / stepGoal).clamp(0.0, 1.0);
}
