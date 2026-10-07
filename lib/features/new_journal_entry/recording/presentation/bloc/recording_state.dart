part of 'recording_bloc.dart';

enum RecordingStatus { idle, recording, paused, done }

class RecordingState extends Equatable {
  final RecordingStatus status;
  final Duration duration;
  final List<double> amplitudeSamples;
  final String? filePath;
  final String? detectedEmotion;
  final double? emotionConfidence;
  final List<double>? recordingCurve;

  const RecordingState({
    this.status = RecordingStatus.idle,
    this.duration = Duration.zero,
    this.amplitudeSamples = const [],
    this.filePath,
    this.detectedEmotion,
    this.emotionConfidence,
    this.recordingCurve,
  });

  bool get hasRecording =>
      status == RecordingStatus.done && filePath != null;

  RecordingState copyWith({
    RecordingStatus? status,
    Duration? duration,
    List<double>? amplitudeSamples,
    String? filePath,
    String? detectedEmotion,
    double? emotionConfidence,
    List<double>? recordingCurve,
  }) =>
      RecordingState(
        status: status ?? this.status,
        duration: duration ?? this.duration,
        amplitudeSamples: amplitudeSamples ?? this.amplitudeSamples,
        filePath: filePath ?? this.filePath,
        detectedEmotion: detectedEmotion ?? this.detectedEmotion,
        emotionConfidence: emotionConfidence ?? this.emotionConfidence,
        recordingCurve: recordingCurve ?? this.recordingCurve,
      );

  @override
  List<Object?> get props => [
        status,
        duration,
        amplitudeSamples,
        filePath,
        detectedEmotion,
        emotionConfidence,
        recordingCurve,
      ];
}