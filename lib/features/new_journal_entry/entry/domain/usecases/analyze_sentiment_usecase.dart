import 'package:dart_sentiment/dart_sentiment.dart';

/// Returns a sentiment score normalised to -1.0 (very negative) → +1.0 (very positive).
class AnalyzeSentimentUseCase {
  final Sentiment _sentiment;

  AnalyzeSentimentUseCase({Sentiment? sentiment})
      : _sentiment = sentiment ?? Sentiment();

  double call(String text) {
    final result = _sentiment.analysis(text, emoji: true);
    final raw = (result['comparative'] as num?)?.toDouble() ?? 0.0;
    return raw.clamp(-1.0, 1.0);
  }
}