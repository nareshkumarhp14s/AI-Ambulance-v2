import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class DriverLocationService {
  DriverLocationService._();

  static final DriverLocationService instance = DriverLocationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Position>? _positionSubscription;

  bool get isTracking => _positionSubscription != null;

  /// Start Live Driver Tracking
  Future<void> startTracking() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Driver is not logged in.");
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location service is disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied.");
    }

    await _positionSubscription?.cancel();

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen(
          (Position position) async {
            try {
              await _firestore.collection("drivers").doc(user.uid).set({
                "latitude": position.latitude,
                "longitude": position.longitude,
                "speed": position.speed,
                "heading": position.heading,
                "accuracy": position.accuracy,
                "altitude": position.altitude,
                "online": true,

                "lastUpdated": FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } catch (e) {
              debugPrint("Driver Location Update Error: $e");
            }
          },
          onError: (e) {
            debugPrint("Location Stream Error: $e");
          },
        );
  }

  /// Stop Tracking
  Future<void> stopTracking() async {
    final user = _auth.currentUser;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (user != null) {
      try {
        await _firestore.collection("drivers").doc(user.uid).update({
          "online": false,
          "lastUpdated": FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  /// Driver goes online
  Future<void> goOnline() async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection("drivers").doc(user.uid).set({
      "online": true,
      "status": "available",
      "lastUpdated": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await startTracking();
  }

  /// Driver goes offline
  Future<void> goOffline() async {
    await stopTracking();
  }
}
