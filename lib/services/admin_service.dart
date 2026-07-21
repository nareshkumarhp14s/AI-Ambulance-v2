import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Total Patients
  Stream<int> patientCount() {
    return _firestore
        .collection("users")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Total Drivers
  Stream<int> driverCount() {
    return _firestore
        .collection("drivers")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Total Hospitals
  Stream<int> hospitalCount() {
    return _firestore
        .collection("hospitals")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Active Trips
  Stream<int> activeTripCount() {
    return _firestore
        .collection("ambulance_assignments")
        .where(
          "status",
          whereIn: [
            "accepted",
            "en_route",
            "arrived",
            "picked_up",
            "hospital_reached",
          ],
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Live Emergency Requests
  Stream<QuerySnapshot<Map<String, dynamic>>> liveRequests() {
    return _firestore
        .collection("emergency_requests")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
