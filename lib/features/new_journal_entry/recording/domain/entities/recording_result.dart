class RecordingResult {
  final String? path;
  final String? detectedEmotion;
  final double? emotionConfidence;
  final List<double> curve;

  const RecordingResult({
    required this.path,
    required this.detectedEmotion,
    required this.emotionConfidence,
    required this.curve,
  });

  factory RecordingResult.empty() => const RecordingResult(
        path: null,
        detectedEmotion: null,
        emotionConfidence: null,
        curve: [],
      );
}