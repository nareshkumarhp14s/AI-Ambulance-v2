import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ambulance_ai_app/core/constants/notification_types.dart';
import '/services/notification_sender.dart';

class DriverAssignmentService {
  DriverAssignmentService._();

  static final DriverAssignmentService instance = DriverAssignmentService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> assignNearestDriver(String requestId) async {
    try {
      final request = await _firestore
          .collection("emergency_requests")
          .doc(requestId)
          .get();

      if (!request.exists) return false;

      final requestData = request.data()!;
      final List rejectedDrivers = requestData["rejectedDrivers"] ?? [];
      final patientLat = (requestData["latitude"] as num).toDouble();

      final patientLng = (requestData["longitude"] as num).toDouble();

      final drivers = await _firestore
          .collection("drivers")
          .where("online", isEqualTo: true)
          .where("status", isEqualTo: "available")
          .get();

      if (drivers.docs.isEmpty) {
        await _firestore.collection("emergency_requests").doc(requestId).update(
          {"status": "no_driver_available"},
        );

        final assignment = await _firestore
            .collection("ambulance_assignments")
            .where("requestId", isEqualTo: requestId)
            .limit(1)
            .get();

        if (assignment.docs.isNotEmpty) {
          await assignment.docs.first.reference.update({
            "status": "no_driver_available",
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }

        return false;
      }

      QueryDocumentSnapshot<Map<String, dynamic>>? nearestDriver;

      double minDistance = double.infinity;

      for (final driver in drivers.docs) {
        if (rejectedDrivers.contains(driver.id)) {
          continue;
        }
        final data = driver.data();

        final distance = _calculateDistance(
          patientLat,
          patientLng,
          (data["latitude"] as num).toDouble(),
          (data["longitude"] as num).toDouble(),
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestDriver = driver;
        }
      }

      if (nearestDriver == null) {
        await _firestore.collection("emergency_requests").doc(requestId).update(
          {"status": "no_driver_available"},
        );

        final assignment = await _firestore
            .collection("ambulance_assignments")
            .where("requestId", isEqualTo: requestId)
            .limit(1)
            .get();

        if (assignment.docs.isNotEmpty) {
          await assignment.docs.first.reference.update({
            "status": "no_driver_available",
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }

        return false;
      }

      final assignmentQuery = await _firestore
          .collection("ambulance_assignments")
          .where("requestId", isEqualTo: requestId)
          .limit(1)
          .get();

      final driverData = nearestDriver.data();

      final eta = max(2, (minDistance / 0.6).round());
      final bookingQuery = await _firestore
          .collection("booking_history")
          .where("requestId", isEqualTo: requestId)
          .limit(1)
          .get();
      final patientId = requestData["patientId"];
      await _firestore.runTransaction((tx) async {
        tx.update(_firestore.collection("emergency_requests").doc(requestId), {
          "driverId": nearestDriver!.id,
          "driverName": driverData["name"] ?? "",
          "driverPhone": driverData["phone"] ?? "",
          "ambulanceNo": driverData["ambulanceNo"] ?? "",
          "status": "assigned",
          "distance": minDistance,
          "eta": "$eta min",
          "assignedAt": FieldValue.serverTimestamp(),
        });

        if (assignmentQuery.docs.isNotEmpty) {
          tx.update(assignmentQuery.docs.first.reference, {
            "driverId": nearestDriver.id,
            "driverName": driverData["name"] ?? "",
            "driverPhone": driverData["phone"] ?? "",
            "ambulanceNo": driverData["ambulanceNo"] ?? "",
            "status": "assigned",
            "distance": minDistance,
            "eta": "$eta min",
            "assignedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }
        if (bookingQuery.docs.isNotEmpty) {
          tx.update(bookingQuery.docs.first.reference, {
            "driverId": nearestDriver.id,
            "driverName": driverData["name"] ?? "",
            "ambulanceNo": driverData["ambulanceNo"] ?? "",
            "status": "assigned",
            "distance": minDistance,
          });
        }
        tx.update(_firestore.collection("drivers").doc(nearestDriver.id), {
          "status": "busy",
          "currentAssignment": requestId,
          "assignedAt": FieldValue.serverTimestamp(),
        });
      });
      await NotificationSender.instance.send(
        userId: patientId,
        bookingId: requestId,
        driverId: nearestDriver.id,
        title: "Driver Assigned",
        body:
            "${driverData["name"]} has been assigned.\nETA: $eta min\nAmbulance: ${driverData["ambulanceNo"]}",
        type: NotificationTypes.driverAssigned,
      );
      return true;
    } catch (e) {
      print("Driver Assignment Error: $e");
      return false;
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radius = 6371.0;

    final dLat = _toRadians(lat2 - lat1);

    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return radius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
