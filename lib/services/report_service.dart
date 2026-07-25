import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportService {
  ReportService._();

  static final ReportService instance = ReportService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Total Emergencies
  Future<int> totalEmergencies() async {
    final data = await _firestore.collection("emergency_requests").get();
    return data.docs.length;
  }

  /// Total Completed Trips
  Future<int> completedTrips() async {
    final data = await _firestore
        .collection("booking_history")
        .where("status", isEqualTo: "completed")
        .get();

    return data.docs.length;
  }

  /// Total Active Drivers
  Future<int> activeDrivers() async {
    final data = await _firestore
        .collection("drivers")
        .where("online", isEqualTo: true)
        .get();

    return data.docs.length;
  }

  /// Total Hospitals
  Future<int> totalHospitals() async {
    final data = await _firestore.collection("hospitals").get();
    return data.docs.length;
  }

  /// Total Patients
  Future<int> totalPatients() async {
    final data = await _firestore.collection("users").get();
    return data.docs.length;
  }

  /// Total Revenue
  Future<double> totalRevenue() async {
    final data = await _firestore.collection("booking_history").get();

    double total = 0;

    for (final doc in data.docs) {
      total += (doc["fare"] ?? 0).toDouble();
    }

    return total;
  }

  /// Dashboard Report
  Future<Map<String, dynamic>> dashboardReport() async {
    return {
      "emergencies": await totalEmergencies(),
      "completedTrips": await completedTrips(),
      "drivers": await activeDrivers(),
      "patients": await totalPatients(),
      "hospitals": await totalHospitals(),
      "revenue": await totalRevenue(),
      "generatedAt": DateFormat("dd MMM yyyy hh:mm a").format(DateTime.now()),
    };
  }
}
