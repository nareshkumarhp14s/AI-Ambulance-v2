import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Position>? _locationSubscription;

  /// Request Permission
  Future<bool> requestPermission() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) return false;

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

  /// Current Position
  Future<Position> getCurrentLocation() async {
    final granted = await requestPermission();

    if (!granted) {
      throw Exception("Location permission denied");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// Start Live Tracking
  Future<void> startTracking() async {
    final user = _auth.currentUser;

    if (user == null) return;

    await stopTracking();

    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((position) async {
          await _firestore.collection("users").doc(user.uid).set({
            "latitude": position.latitude,
            "longitude": position.longitude,
            "lastUpdated": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final driver = await _firestore
              .collection("drivers")
              .doc(user.uid)
              .get();

          if (driver.exists) {
            await driver.reference.set({
              "latitude": position.latitude,
              "longitude": position.longitude,
              "speed": position.speed,
              "heading": position.heading,
              "lastUpdated": FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        });
  }

  /// Stop Tracking
  Future<void> stopTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Check GPS
  Future<bool> isGpsEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Distance in KM
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final meters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );

    return meters / 1000;
  }

  /// Dispose
  void dispose() {
    _locationSubscription?.cancel();
  }
}
