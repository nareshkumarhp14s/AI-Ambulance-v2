import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  StreamSubscription<Position>? _positionStream;

  void startTracking() {
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          await FirebaseFirestore.instance
              .collection('ambulance_tracking')
              .doc('Xc5xkWVL9wHMi5Zjj9TO')
              .update({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'status': 'on_the_way',
              });
        });
  }

  void stopTracking() {
    _positionStream?.cancel();
  }
}
