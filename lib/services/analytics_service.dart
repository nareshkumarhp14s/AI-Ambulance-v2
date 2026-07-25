import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> totalEmergencies() async {
    final snapshot = await _firestore.collection("emergency_requests").get();

    return snapshot.docs.length;
  }

  Future<int> activeEmergencies() async {
    final snapshot = await _firestore
        .collection("emergency_requests")
        .where(
          "status",
          whereIn: ["searching", "pending", "accepted", "picked_up"],
        )
        .get();

    return snapshot.docs.length;
  }

  Future<int> completedTrips() async {
    final snapshot = await _firestore
        .collection("booking_history")
        .where("status", isEqualTo: "completed")
        .get();

    return snapshot.docs.length;
  }

  Future<int> onlineDrivers() async {
    final snapshot = await _firestore
        .collection("drivers")
        .where("online", isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  Future<int> offlineDrivers() async {
    final snapshot = await _firestore
        .collection("drivers")
        .where("online", isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  Future<int> totalHospitals() async {
    final snapshot = await _firestore.collection("hospitals").get();

    return snapshot.docs.length;
  }

  Future<double> totalRevenue() async {
    final snapshot = await _firestore.collection("booking_history").get();

    double revenue = 0;

    for (final doc in snapshot.docs) {
      revenue += (doc["fare"] ?? 0).toDouble();
    }

    return revenue;
  }

  Future<double> averageDriverRating() async {
    final snapshot = await _firestore.collection("drivers").get();

    if (snapshot.docs.isEmpty) return 0;

    double rating = 0;

    for (final doc in snapshot.docs) {
      rating += (doc["rating"] ?? 0).toDouble();
    }

    return rating / snapshot.docs.length;
  }

  Future<double> averageResponseTime() async {
    final snapshot = await _firestore
        .collection("booking_history")
        .where("status", isEqualTo: "completed")
        .get();

    if (snapshot.docs.isEmpty) return 0;

    double total = 0;

    for (final doc in snapshot.docs) {
      total += (doc["tripDuration"] ?? 0).toDouble();
    }

    return total / snapshot.docs.length;
  }

  Future<Map<String, dynamic>> dashboard() async {
    return {
      "totalEmergencies": await totalEmergencies(),
      "activeEmergencies": await activeEmergencies(),
      "completedTrips": await completedTrips(),
      "onlineDrivers": await onlineDrivers(),
      "offlineDrivers": await offlineDrivers(),
      "totalHospitals": await totalHospitals(),
      "averageRating": await averageDriverRating(),
      "averageResponseTime": await averageResponseTime(),
      "revenue": await totalRevenue(),
    };
  }
}
