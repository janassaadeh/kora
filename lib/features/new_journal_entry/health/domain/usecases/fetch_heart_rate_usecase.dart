import '../repositories/health_repository.dart';

class FetchHeartRateUseCase {
  final HealthRepository _repository;

  /// The minimum time to wait before returning, so the UI scan animation
  /// has time to display. Defaults to 3 s; override in tests.
  final Duration minScanDuration;

  const FetchHeartRateUseCase(
    this._repository, {
    this.minScanDuration = const Duration(seconds: 3),
  });

  Future<int?> call() async {
    final stopwatch = Stopwatch()..start();
    final bpm = await _repository.fetchLatestHeartRate();

    final remaining = minScanDuration - stopwatch.elapsed;
    if (!remaining.isNegative) await Future.delayed(remaining);

    return bpm;
  }
}