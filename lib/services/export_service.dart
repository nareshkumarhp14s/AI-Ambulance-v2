import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<File> exportBookingHistoryCSV() async {
    final snapshot = await _firestore
        .collection("booking_history")
        .orderBy("createdAt", descending: true)
        .get();

    final List<List<dynamic>> rows = [];

    rows.add([
      "Patient",
      "Driver",
      "Ambulance",
      "Hospital",
      "Status",
      "Distance(km)",
      "Duration(min)",
      "Fare",
    ]);

    for (final doc in snapshot.docs) {
      final data = doc.data();

      rows.add([
        data["patientName"] ?? "",
        data["driverName"] ?? "",
        data["ambulanceNo"] ?? "",
        data["hospitalName"] ?? "",
        data["status"] ?? "",
        data["distance"] ?? 0,
        data["tripDuration"] ?? 0,
        data["fare"] ?? 0,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();

    final file = File("${directory.path}/BookingHistory.csv");

    await file.writeAsString(csv);

    return file;
  }

  Future<File> exportDriversCSV() async {
    final snapshot = await _firestore.collection("drivers").get();

    final rows = <List<dynamic>>[];

    rows.add(["Name", "Phone", "Ambulance", "Status", "Rating", "Trips"]);

    for (final doc in snapshot.docs) {
      final data = doc.data();

      rows.add([
        data["name"] ?? "",
        data["phone"] ?? "",
        data["ambulanceNo"] ?? "",
        data["status"] ?? "",
        data["rating"] ?? 0,
        data["totalTrips"] ?? 0,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();

    final file = File("${directory.path}/Drivers.csv");

    await file.writeAsString(csv);

    return file;
  }

  Future<File> exportHospitalsCSV() async {
    final snapshot = await _firestore.collection("hospitals").get();

    final rows = <List<dynamic>>[];

    rows.add(["Hospital", "Beds", "Latitude", "Longitude"]);

    for (final doc in snapshot.docs) {
      final data = doc.data();

      rows.add([
        data["name"] ?? "",
        data["availableBeds"] ?? 0,
        data["latitude"] ?? 0,
        data["longitude"] ?? 0,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();

    final file = File("${directory.path}/Hospitals.csv");

    await file.writeAsString(csv);

    return file;
  }
}
