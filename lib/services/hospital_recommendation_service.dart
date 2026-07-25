import 'package:cloud_firestore/cloud_firestore.dart';
import 'hospital_service.dart';

class HospitalRecommendationService {
  HospitalRecommendationService._();

  static final HospitalRecommendationService instance =
      HospitalRecommendationService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> assignHospital({
    required String requestId,
  }) async {
    final snapshot = await firestore
        .collection("hospitals")
        .where("emergencyAvailable", isEqualTo: true)
        .where("availableBeds", isGreaterThan: 0)
        .orderBy("availableBeds")
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final hospital = snapshot.docs.first;
    final data = hospital.data();

    final reserved = await HospitalService.reserveBed(hospital.id);

    if (!reserved) return null;

    final updateData = {
      "hospitalId": hospital.id,
      "hospitalName": data["name"] ?? "",
      "hospitalPhone": data["phone"] ?? "",
      "hospitalLatitude": data["latitude"] ?? 0,
      "hospitalLongitude": data["longitude"] ?? 0,
      "bedReserved": true,
    };

    // Emergency Request
    await firestore
        .collection("emergency_requests")
        .doc(requestId)
        .update(updateData);

    // Assignment
    final assignment = await firestore
        .collection("ambulance_assignments")
        .where("requestId", isEqualTo: requestId)
        .limit(1)
        .get();

    if (assignment.docs.isNotEmpty) {
      await assignment.docs.first.reference.update({
        ...updateData,
        "destinationLatitude": data["latitude"] ?? 0,
        "destinationLongitude": data["longitude"] ?? 0,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    // Booking History
    final history = await firestore
        .collection("booking_history")
        .where("requestId", isEqualTo: requestId)
        .limit(1)
        .get();

    if (history.docs.isNotEmpty) {
      await history.docs.first.reference.update({
        "hospitalId": hospital.id,
        "hospitalName": data["name"] ?? "",
        "hospitalPhone": data["phone"] ?? "",
        "bedReserved": true,
      });
    }

    return updateData;
  }
}
