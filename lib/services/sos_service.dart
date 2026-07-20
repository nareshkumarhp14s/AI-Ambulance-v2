import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SosService {
  SosService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createEmergency({
    required double latitude,
    required double longitude,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final batch = _firestore.batch();

    final emergencyRef = _firestore.collection("emergency_requests").doc();

    final assignmentRef = _firestore.collection("ambulance_assignments").doc();

    final historyRef = _firestore.collection("booking_history").doc();

    batch.set(emergencyRef, {
      "requestId": emergencyRef.id,
      "patientId": user.uid,
      "type": "SOS",
      "patientCondition": "Critical",
      "location": {"latitude": latitude, "longitude": longitude},
      "driverId": null,
      "ambulanceId": null,
      "status": "searching",
      "createdAt": FieldValue.serverTimestamp(),
    });

    batch.set(assignmentRef, {
      "assignmentId": assignmentRef.id,
      "requestId": emergencyRef.id,
      "driverId": null,
      "status": "searching",
      "createdAt": FieldValue.serverTimestamp(),
    });

    batch.set(historyRef, {
      "requestId": emergencyRef.id,
      "patientId": user.uid,
      "status": "searching",
      "hospitalName": "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return emergencyRef.id;
  }
}
