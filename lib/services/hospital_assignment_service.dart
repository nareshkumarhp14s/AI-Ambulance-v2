import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalAssignmentService {
  HospitalAssignmentService._();

  static final HospitalAssignmentService instance =
      HospitalAssignmentService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> assignNearestHospital(String requestId) async {
    try {
      final requestDoc = await _firestore
          .collection("emergency_requests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return false;

      final request = requestDoc.data()!;

      final double patientLat = (request["latitude"] as num).toDouble();

      final double patientLng = (request["longitude"] as num).toDouble();

      final hospitals = await _firestore
          .collection("hospitals")
          .where("availableBeds", isGreaterThan: 0)
          .get();

      if (hospitals.docs.isEmpty) {
        return false;
      }

      QueryDocumentSnapshot<Map<String, dynamic>>? nearestHospital;

      double shortestDistance = double.infinity;

      for (final hospital in hospitals.docs) {
        final data = hospital.data();

        final double lat = (data["latitude"] as num).toDouble();

        final double lng = (data["longitude"] as num).toDouble();

        final distance = _calculateDistance(patientLat, patientLng, lat, lng);

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestHospital = hospital;
        }
      }

      if (nearestHospital == null) return false;

      final assignment = await _firestore
          .collection("ambulance_assignments")
          .where("requestId", isEqualTo: requestId)
          .limit(1)
          .get();

      final booking = await _firestore
          .collection("booking_history")
          .where("requestId", isEqualTo: requestId)
          .limit(1)
          .get();

      await _firestore.runTransaction((tx) async {
        tx.update(requestDoc.reference, {
          "hospitalId": nearestHospital!.id,
          "hospitalName": nearestHospital.data()["name"],
          "hospitalLatitude": nearestHospital.data()["latitude"],
          "hospitalLongitude": nearestHospital.data()["longitude"],
          "hospitalDistance": shortestDistance,
          "updatedAt": FieldValue.serverTimestamp(),
        });

        if (assignment.docs.isNotEmpty) {
          tx.update(assignment.docs.first.reference, {
            "hospitalId": nearestHospital.id,
            "hospitalName": nearestHospital.data()["name"],
            "destinationLatitude": nearestHospital.data()["latitude"],
            "destinationLongitude": nearestHospital.data()["longitude"],
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }

        if (booking.docs.isNotEmpty) {
          tx.update(booking.docs.first.reference, {
            "hospitalId": nearestHospital.id,
            "hospitalName": nearestHospital.data()["name"],
          });
        }

        tx.update(nearestHospital.reference, {
          "availableBeds": FieldValue.increment(-1),
        });
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radius = 6371;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return radius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
  }
}
