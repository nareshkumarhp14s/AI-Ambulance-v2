import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/notification_sender.dart';
import 'package:ambulance_ai_app/core/constants/notification_types.dart';
import 'hospital_service.dart';

class DriverTripService {
  DriverTripService._();

  static final DriverTripService instance = DriverTripService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> acceptRequest({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "accepted",
      "acceptedAt": FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "accepted",
      "acceptedAt": FieldValue.serverTimestamp(),
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "accepted",
        "acceptedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (assignment != null) {
      final data = assignment.data();

      await NotificationSender.instance.send(
        userId: data["patientId"],
        bookingId: requestId,
        driverId: driverId,
        title: "Driver Assigned",
        body: "${data["driverName"]} has accepted your ambulance request.",
        type: NotificationTypes.driverAssigned,
      );
    }
  }

  Future<void> startTrip({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "en_route",
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "en_route",
      "pickupAt": FieldValue.serverTimestamp(),
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "en_route",
        "pickupAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (assignment != null) {
      final data = assignment.data();

      await NotificationSender.instance.send(
        userId: data["patientId"],
        bookingId: requestId,
        driverId: driverId,
        title: "Driver is on the way",
        body:
            "${data["driverName"]} has started the trip and is coming to your location.",
        type: "trip_started",
      );
    }
  }

  Future<void> arriveAtPatient({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "arrived",
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "arrived",
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "arrived",
        "arrivedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (assignment != null) {
      final data = assignment.data();

      await NotificationSender.instance.send(
        userId: data["patientId"],
        bookingId: requestId,
        driverId: driverId,
        title: "Driver Arrived",
        body: "${data["driverName"]} has reached your pickup location.",
        type: NotificationTypes.driverArrived,
      );
    }
  }

  Future<void> pickupPatient({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "picked_up",
      "pickedUpAt": FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "picked_up",
      "pickedUpAt": FieldValue.serverTimestamp(),
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "picked_up",
        "pickedUpAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (assignment != null) {
      final data = assignment.data();

      await NotificationSender.instance.send(
        userId: data["patientId"],
        bookingId: requestId,
        driverId: driverId,
        title: "Patient Picked Up",
        body: "You are now on the way to the hospital.",
        type: NotificationTypes.patientPickedUp,
      );
    }
  }

  Future<void> reachHospital({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "hospital_reached",
      "hospitalReachedAt": FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "hospital_reached",
      "hospitalReachedAt": FieldValue.serverTimestamp(),
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "hospital_reached",
        "hospitalReachedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (assignment != null) {
      final data = assignment.data();

      await NotificationSender.instance.send(
        userId: data["patientId"],
        bookingId: requestId,
        driverId: driverId,
        title: "Hospital Reached",
        body:
            "You have successfully reached ${data["hospitalName"] ?? "the hospital"}.",
        type: "hospital_reached",
      );
    }
  }

  Future<void> completeTrip({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "available",
      "currentAssignment": "",
      "completedAt": FieldValue.serverTimestamp(),
      "lastUpdated": FieldValue.serverTimestamp(),
      "totalTrips": FieldValue.increment(1),
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "completed",
      "completedAt": FieldValue.serverTimestamp(),
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "completed",
        "completedAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    final history = await _firestore
        .collection("booking_history")
        .where("requestId", isEqualTo: requestId)
        .limit(1)
        .get();

    if (history.docs.isNotEmpty && assignment != null) {
      final assignmentData = assignment.data();

      batch.update(history.docs.first.reference, {
        "driverId": assignmentData["driverId"],
        "driverName": assignmentData["driverName"],
        "patientId": assignmentData["patientId"],
        "patientName": assignmentData["patientName"],
        "patientPhone": assignmentData["patientPhone"],
        "ambulanceNo": assignmentData["ambulanceNo"],
        "hospitalId": assignmentData["hospitalId"],
        "hospitalName": assignmentData["hospitalName"],
        "distance": assignmentData["distance"],
        "status": "completed",
        "completedAt": FieldValue.serverTimestamp(),
      });
    }

    try {
      print("=== COMPLETE TRIP START ===");
      print("RequestId: $requestId");
      print("DriverId: $driverId");

      await batch.commit();
      if (assignment != null) {
        final hospitalId = assignment.data()["hospitalId"];

        if (hospitalId != null && hospitalId.toString().isNotEmpty) {
          await HospitalService.releaseBed(hospitalId);
        }
      }
      if (assignment != null) {
        final data = assignment.data();

        await NotificationSender.instance.send(
          userId: data["patientId"],
          bookingId: requestId,
          driverId: driverId,
          title: "Trip Completed",
          body: "Your ambulance trip has been completed successfully.",
          type: NotificationTypes.tripCompleted,
        );
      }

      print("=== BATCH COMMIT SUCCESS ===");
    } catch (e, stackTrace) {
      print("=== BATCH COMMIT FAILED ===");
      print(e);
      print(stackTrace);
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String driverId,
  }) async {
    final assignment = await _assignment(requestId);

    final batch = _firestore.batch();

    batch.update(_firestore.collection("drivers").doc(driverId), {
      "status": "available",
      "currentAssignment": "",
    });

    batch.update(_firestore.collection("emergency_requests").doc(requestId), {
      "status": "searching",
      "driverId": null,
      "driverName": "",
      "driverPhone": "",
      "ambulanceNo": "",
    });

    if (assignment != null) {
      batch.update(assignment.reference, {
        "status": "searching",
        "driverId": null,
        "driverName": "",
        "driverPhone": "",
        "ambulanceNo": "",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _assignment(
    String requestId,
  ) async {
    final query = await _firestore
        .collection("ambulance_assignments")
        .where("requestId", isEqualTo: requestId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first;
  }
}
