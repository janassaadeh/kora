abstract class LocationRepository {
  /// Returns a human-readable city string (e.g. "Beirut, Lebanon"),
  /// or null if permission was denied or no position is available.
  Future<String?> resolveCurrentCity();
}