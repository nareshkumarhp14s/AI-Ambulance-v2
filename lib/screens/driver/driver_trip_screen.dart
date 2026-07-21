import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/driver_location_service.dart';

class DriverTripScreen extends StatefulWidget {
  const DriverTripScreen({super.key});

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DriverLocationService locationService = DriverLocationService();

  Future<void> updateTripStatus(
    String assignmentId,
    String requestId,
    String status,
  ) async {
    final batch = firestore.batch();

    batch.update(
      firestore.collection("ambulance_assignments").doc(assignmentId),
      {"status": status},
    );

    batch.update(firestore.collection("emergency_requests").doc(requestId), {
      "status": status,
    });

    if (status == "completed") {
      final assignment = await firestore
          .collection("ambulance_assignments")
          .doc(assignmentId)
          .get();

      if (assignment.exists) {
        final data = assignment.data()!;

        batch.set(firestore.collection("booking_history").doc(), {
          ...data,
          "status": "completed",
          "completedAt": FieldValue.serverTimestamp(),
        });

        batch.update(firestore.collection("drivers").doc(data["driverId"]), {
          "status": "available",
          "currentAssignment": null,
        });
      }

      locationService.stopTracking();
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Active Trip"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
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
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Active Trip", style: TextStyle(fontSize: 18)),
            );
          }

          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          final status = data["status"] ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(data["patientName"] ?? ""),
                    subtitle: Text(data["patientPhone"] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.emergency),
                    title: Text(data["emergencyType"] ?? ""),
                    subtitle: Text(data["pickupAddress"] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: Text(data["hospitalName"] ?? ""),
                    subtitle: const Text("Destination Hospital"),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Chip(
                    label: Text(
                      status.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                ),

                const SizedBox(height: 30),

                if (status == "accepted")
                  _button("Start Trip", () {
                    locationService.startTracking();

                    updateTripStatus(doc.id, data["requestId"], "en_route");
                  }),

                if (status == "en_route")
                  _button("Reached Patient", () {
                    updateTripStatus(doc.id, data["requestId"], "arrived");
                  }),

                if (status == "arrived")
                  _button("Pickup Patient", () {
                    updateTripStatus(doc.id, data["requestId"], "picked_up");
                  }),

                if (status == "picked_up")
                  _button("Reached Hospital", () {
                    updateTripStatus(
                      doc.id,
                      data["requestId"],
                      "hospital_reached",
                    );
                  }),

                if (status == "hospital_reached")
                  _button("Complete Trip", () {
                    updateTripStatus(doc.id, data["requestId"], "completed");
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _button(String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(onPressed: onPressed, child: Text(title)),
      ),
    );
  }
}
