import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  MapService._();

  static final MapService instance = MapService._();

  /// Request Location Permission
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Current Location
  Future<Position> getCurrentLocation() async {
    final granted = await requestLocationPermission();

    if (!granted) {
      throw Exception("Location permission denied");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  /// Live Location Stream
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }

  /// Calculate Distance (KM)
  double calculateDistance({required LatLng start, required LatLng end}) {
    final meter = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    return meter / 1000;
  }

  /// Reverse Geocoding
  Future<String> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final places = await placemarkFromCoordinates(latitude, longitude);

      if (places.isEmpty) return "";

      final place = places.first;

      return [
        place.subLocality,
        place.locality,
      ].where((e) => e != null && e.isNotEmpty).join(", ");
    } catch (_) {
      return "";
    }
  }

  /// Open Google Maps Camera Position
  Future<CameraPosition> currentCamera() async {
    final position = await getCurrentLocation();

    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 17,
    );
  }

  /// Bearing Between Two Points
  double getBearing({required LatLng start, required LatLng end}) {
    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Check GPS
  Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }
}
