import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyService {
  EmergencyService();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> sendEmergency({
    required String type,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
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

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final batch = firestore.batch();

    final requestRef = firestore.collection("emergency_requests").doc();

    final assignmentRef = firestore.collection("ambulance_assignments").doc();

    final historyRef = firestore.collection("booking_history").doc();

    batch.set(requestRef, {
      "requestId": requestRef.id,
      "patientId": user.uid,
      "type": type,
      "description": description,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "driverId": null,
      "ambulanceId": null,
      "status": "searching",
      "createdAt": FieldValue.serverTimestamp(),
    });

    batch.set(assignmentRef, {
      "assignmentId": assignmentRef.id,
      "requestId": requestRef.id,
      "patientId": user.uid,
      "driverId": null,
      "status": "searching",
      "createdAt": FieldValue.serverTimestamp(),
    });

    batch.set(historyRef, {
      "requestId": requestRef.id,
      "patientId": user.uid,
      "hospitalName": "",
      "status": "searching",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return requestRef.id;
  }
}
