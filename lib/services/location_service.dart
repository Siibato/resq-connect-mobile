import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _cacheKeyLat = 'cached_latitude';
  static const _cacheKeyLng = 'cached_longitude';
  static const _cacheKeyTime = 'cached_location_time';

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // Cache the location with timestamp
    _cacheLocation(position.latitude, position.longitude);

    return position;
  }

  /// Get last known location from cache
  /// Useful for offline mode when GPS is not available
  Future<Position?> getLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_cacheKeyLat);
      final lng = prefs.getDouble(_cacheKeyLng);
      final timeStr = prefs.getString(_cacheKeyTime);

      if (lat != null && lng != null) {
        final timestamp = timeStr != null ? DateTime.parse(timeStr) : DateTime.now();
        return Position(
          latitude: lat,
          longitude: lng,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: timestamp,
          headingAccuracy: 0,
          altitudeAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the age of cached location in minutes
  Future<int?> getCacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_cacheKeyTime);
      if (timeStr == null) return null;

      final cachedTime = DateTime.parse(timeStr);
      final now = DateTime.now();
      return now.difference(cachedTime).inMinutes;
    } catch (e) {
      return null;
    }
  }

  /// Cache location to shared preferences
  Future<void> _cacheLocation(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheKeyLat, lat);
      await prefs.setDouble(_cacheKeyLng, lng);
      await prefs.setString(_cacheKeyTime, DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail caching
    }
  }

  /// Get formatted location string for display
  String getAddressFromCoordinates(double lat, double lng) {
    // Simple coordinate display since we don't have a geocoding API
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  /// Get space-separated coordinates for SMS format
  String getFormattedCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(4)} ${lng.toStringAsFixed(4)}';
  }
}
