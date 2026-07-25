import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get users => firestore.collection("users");

  CollectionReference get drivers => firestore.collection("drivers");

  CollectionReference get hospitals => firestore.collection("hospitals");

  CollectionReference get emergencyRequests =>
      firestore.collection("emergency_requests");

  CollectionReference get ambulanceAssignments =>
      firestore.collection("ambulance_assignments");

  CollectionReference get bookingHistory =>
      firestore.collection("booking_history");

  CollectionReference get ambulanceTracking =>
      firestore.collection("ambulance_tracking");
  CollectionReference get notifications =>
      firestore.collection("notifications");
  Future<DocumentSnapshot> getUser(String uid) {
    return users.doc(uid).get();
  }

  Future<DocumentSnapshot> getDriver(String uid) {
    return drivers.doc(uid).get();
  }

  Future<DocumentSnapshot> getHospital(String id) {
    return hospitals.doc(id).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return users.doc(uid).update(data);
  }

  Future<void> updateDriver(String uid, Map<String, dynamic> data) {
    return drivers.doc(uid).update(data);
  }

  Future<void> updateHospital(String id, Map<String, dynamic> data) {
    return hospitals.doc(id).update(data);
  }

  Future<void> updateEmergency(String requestId, Map<String, dynamic> data) {
    return emergencyRequests.doc(requestId).update(data);
  }

  Future<void> deleteEmergency(String requestId) {
    return emergencyRequests.doc(requestId).delete();
  }

  WriteBatch batch() => firestore.batch();

  Future<T> runTransaction<T>(TransactionHandler<T> handler) {
    return firestore.runTransaction(handler);
  }
}
