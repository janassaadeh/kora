class EmotionResult {
  final String emotion;
  final double confidence;
  final Map<String, double> allProbabilities;

  const EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.allProbabilities,
  });
}