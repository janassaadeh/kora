class AudioNormalizer {
  static List<double> normalize(List<double> input) {
   if (input.isEmpty) return List.filled(9, 0.0);

    // 1. Normalize to 0..1
    final min = input.reduce((a, b) => a < b ? a : b);
    final max = input.reduce((a, b) => a > b ? a : b);
    final range = (max - min);

    final normalized = range == 0
        ? List.filled(input.length, 0.5)
        : input.map((v) => (v - min) / range).toList();

    // 2. Force exactly 9 bars
    final bars = List<double>.filled(9, 0.0);
    final chunkSize = (normalized.length / 9).ceil();

    for (int i = 0; i < 9; i++) {
      final start = i * chunkSize;
      if (start >= normalized.length) break;

      final end = (start + chunkSize).clamp(0, normalized.length);
      final chunk = normalized.sublist(start, end);

      if (chunk.isNotEmpty) {
        bars[i] = chunk.reduce((a, b) => a + b) / chunk.length;
      }
    }

    // 3. Make visual contrast better (important for UI)
    return bars.map((v) {
      final boosted = (v * 1.35).clamp(0.05, 1.0);
      return boosted;
    }).toList();
  }
}