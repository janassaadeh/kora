// import 'package:kora/core/utils/audio_normalizer.dart';

// /// Extracts and normalises the spectrogram amplitude curve from a recording.
// /// Normalisation is domain logic — the bloc never touches [AudioNormalizer].
import 'package:kora/core/utils/audio_normalizer.dart';

class ExtractSpectrogramCurveUseCase {
  // Injected so the raw extraction strategy can be swapped (e.g. in tests).
  final Future<List<double>> Function(String path) _rawExtractor;

  const ExtractSpectrogramCurveUseCase(this._rawExtractor);

  Future<List<double>> call(String path) async {
    final raw = await _rawExtractor(path);
    return AudioNormalizer.normalize(raw);
  }
}