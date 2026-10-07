import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<String?> resolveCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException {
        debugPrint('getCurrentPosition timed out — trying last known');
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) return null;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final cityPart = (p.locality?.isNotEmpty ?? false)
          ? p.locality!
          : (p.administrativeArea ?? '');
      final country = p.country ?? '';
      final city = [cityPart, country]
          .where((s) => s.isNotEmpty)
          .join(', ');

      return city.isNotEmpty ? city : null;
    } catch (e, stack) {
      debugPrint('Location resolution failed: $e\n$stack');
      return null;
    }
  }
}