import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'driver_assignment_service.dart';
import 'hospital_recommendation_service.dart';
import '/services/notification_sender.dart';
import 'package:ambulance_ai_app/core/constants/notification_types.dart';

class EmergencyService {
  EmergencyService();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> sendEmergency({
    required String type,
    required String description,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    // Check GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Please enable Location Service.");
    }

    // Permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied.");
    }

    // Current Location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // Patient Details
    final userDoc = await firestore.collection("users").doc(user.uid).get();

    if (!userDoc.exists) {
      throw Exception("Patient profile not found.");
    }

    final userData = userDoc.data()!;

    final WriteBatch batch = firestore.batch();

    final requestRef = firestore.collection("emergency_requests").doc();

    final assignmentRef = firestore.collection("ambulance_assignments").doc();

    final historyRef = firestore.collection("booking_history").doc();

    // ----------------------------------------------------
    // Emergency Request
    // ----------------------------------------------------

    batch.set(requestRef, {
      "requestId": requestRef.id,

      "patientId": user.uid,
      "patientName": userData["name"] ?? "",
      "patientPhone": userData["phone"] ?? "",

      "driverId": null,

      "hospitalId": "",
      "hospitalName": "",
      "hospitalPhone": "",
      "hospitalLatitude": 0,
      "hospitalLongitude": 0,
      "bedReserved": false,

      "latitude": position.latitude,
      "longitude": position.longitude,

      "type": type,
      "description": description,

      "priority": "High",
      "rejectedDrivers": [],

      "status": "searching",

      "distance": 0,

      "eta": "",

      "assignedAt": null,

      "completedAt": null,

      "createdAt": FieldValue.serverTimestamp(),
    });

    // ----------------------------------------------------
    // Assignment
    // ----------------------------------------------------

    batch.set(assignmentRef, {
      "assignmentId": assignmentRef.id,

      "requestId": requestRef.id,

      "patientId": user.uid,
      "patientName": userData["name"] ?? "",
      "patientPhone": userData["phone"] ?? "",

      "ambulanceNo": "",

      "hospitalId": "",
      "hospitalName": "",
      "hospitalPhone": "",
      "hospitalLatitude": 0,
      "hospitalLongitude": 0,
      "bedReserved": false,

      "pickupLatitude": position.latitude,
      "pickupLongitude": position.longitude,

      "destinationLatitude": null,
      "destinationLongitude": null,

      "status": "searching",

      "distance": 0,

      "eta": "",

      "acceptedAt": null,

      "pickupAt": null,

      "completedAt": null,

      "createdAt": FieldValue.serverTimestamp(),

      "updatedAt": FieldValue.serverTimestamp(),
    });

    // ----------------------------------------------------
    // Booking History
    // ----------------------------------------------------

    batch.set(historyRef, {
      "requestId": requestRef.id,

      "patientId": user.uid,

      "driverId": "",

      "driverName": "",

      "ambulanceNo": "",

      "hospitalId": "",
      "hospitalName": "",
      "hospitalPhone": "",
      "bedReserved": false,

      "pickupLocation": "",

      "destination": "",

      "distance": 0,

      "tripDuration": 0,

      "fare": 0,

      "status": "searching",

      "completedAt": null,

      "createdAt": FieldValue.serverTimestamp(),
    });

    await batch.commit();

    await firestore.collection("emergency_requests").doc(requestRef.id).update({
      "rejectedDrivers": FieldValue.arrayUnion([""]),
    });
    await NotificationSender.instance.send(
      userId: user.uid,
      bookingId: requestRef.id,
      title: "Ambulance Booked",
      body: "Your ambulance request has been received.",
      type: NotificationTypes.bookingCreated,
    );

    final assigned = await DriverAssignmentService.instance.assignNearestDriver(
      requestRef.id,
    );
    await HospitalRecommendationService.instance.assignHospital(
      requestId: requestRef.id,
    );
    if (!assigned) {
      await firestore
          .collection("emergency_requests")
          .doc(requestRef.id)
          .update({"status": "waiting_driver"});

      await firestore
          .collection("ambulance_assignments")
          .doc(assignmentRef.id)
          .update({
            "status": "waiting_driver",
            "updatedAt": FieldValue.serverTimestamp(),
          });

      await firestore.collection("booking_history").doc(historyRef.id).update({
        "status": "waiting_driver",
      });
    }

    return requestRef.id;
  }
}
