import '../entities/recording_tick.dart';

/// Domain boundary for all audio I/O.
/// Infrastructure owns AudioRecorder, Timer, and Directory — this interface
/// is the only thing the domain and presentation layers ever touch.
abstract class AudioRepository {
  Future<bool> hasPermission();

  /// Starts a recording and returns the file path it will be saved to.
  Future<String> startRecording();

  Future<void> pauseRecording();

  Future<void> resumeRecording();

  /// Stops the recording and returns the final file path, or null on failure.
  Future<String?> stopRecording();

  /// Cancels an in-progress recording and discards the file.
  Future<void> cancelRecording();

  /// Emits a [RecordingTick] roughly every 100 ms while recording is active.
  /// The stream completes when [stopRecording] or [cancelRecording] is called.
  Stream<RecordingTick> get tickStream;
}