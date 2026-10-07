/// Pure domain use case — no I/O, no Flutter imports.
/// Takes all inputs explicitly so it is trivially unit-testable.
class CalculateVitalityUseCase {
  const CalculateVitalityUseCase();

  int call({
    required int? heartRate,
    required int totalSteps,
    required String? detectedEmotion,
    required double? sentimentScore,
  }) {
    final hr = heartRate ?? 72;
    int score = 50;

    // ── Heart rate (+15 max) ──────────────────────────────────────────────
    if (hr >= 55 && hr <= 85) score += 10;
    if (hr >= 60 && hr <= 75) score += 5;

    // ── Steps (+20 max, tiered) ───────────────────────────────────────────
    if (totalSteps >= 3000) score += 5;
    if (totalSteps >= 6000) score += 5;
    if (totalSteps >= 8000) score += 5;
    if (totalSteps >= 10000) score += 5;

    // ── Voice emotion (±15 pts) ───────────────────────────────────────────
    const emotionScores = {
      'happy': 15,
      'neutral': 5,
      'sad': -10,
      'angry': -15,
      'fearful': -15,
    };
    score += emotionScores[detectedEmotion] ?? 0;

    // ── Text sentiment (±10 pts) ──────────────────────────────────────────
    if (sentimentScore != null) {
      score += (sentimentScore * 10).round();
    }

    return score.clamp(0, 100);
  }
}