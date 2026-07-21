import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverRequestsScreen extends StatefulWidget {
  const DriverRequestsScreen({super.key});

  @override
  State<DriverRequestsScreen> createState() => _DriverRequestsScreenState();
}

class _DriverRequestsScreenState extends State<DriverRequestsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> acceptRequest(
    String assignmentId,
    String driverId,
    String requestId,
  ) async {
    final batch = firestore.batch();

    batch.update(
      firestore.collection("ambulance_assignments").doc(assignmentId),
      {"status": "accepted", "acceptedAt": FieldValue.serverTimestamp()},
    );

    batch.update(firestore.collection("drivers").doc(driverId), {
      "status": "busy",
    });

    batch.update(firestore.collection("emergency_requests").doc(requestId), {
      "status": "accepted",
      "driverId": driverId,
    });

    await batch.commit();
  }

  Future<void> rejectRequest(
    String assignmentId,
    String driverId,
    String requestId,
  ) async {
    final batch = firestore.batch();

    batch.update(
      firestore.collection("ambulance_assignments").doc(assignmentId),
      {"status": "rejected"},
    );

    batch.update(firestore.collection("drivers").doc(driverId), {
      "status": "available",
    });

    batch.update(firestore.collection("emergency_requests").doc(requestId), {
      "status": "waiting",
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Requests"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("ambulance_assignments")
            .where("status", isEqualTo: "pending")
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                "No Emergency Requests",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];

              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: const [
                          Icon(Icons.emergency, color: Colors.red),

                          SizedBox(width: 10),

                          Text(
                            "Emergency Request",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      Text("Patient : ${data["patientName"] ?? "Unknown"}"),

                      Text("Emergency : ${data["emergencyType"] ?? "Unknown"}"),

                      Text("Hospital : ${data["hospitalName"] ?? "Unknown"}"),

                      Text("Pickup : ${data["pickupAddress"] ?? "Unknown"}"),

                      Text("Phone : ${data["patientPhone"] ?? "Unknown"}"),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),

                              label: const Text("Accept"),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),

                              onPressed: () async {
                                await acceptRequest(
                                  doc.id,
                                  data["driverId"],
                                  data["requestId"],
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Request Accepted"),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.close),

                              label: const Text("Reject"),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),

                              onPressed: () async {
                                await rejectRequest(
                                  doc.id,
                                  data["driverId"],
                                  data["requestId"],
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Request Rejected"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
