import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    print("Logged in Driver UID: $uid");

    return Scaffold(
      appBar: AppBar(title: const Text("Trip History"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("booking_history")
            .where("driverId", isEqualTo: uid)
            .where("status", isEqualTo: "completed")
            .orderBy("completedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("History Error: ${snapshot.error}");

            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          print("History Docs Count: ${docs.length}");

          if (docs.isEmpty) {
            return const Center(
              child: Text("No Completed Trips", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              print(data);

              DateTime? completedTime;

              if (data["completedAt"] != null &&
                  data["completedAt"] is Timestamp) {
                completedTime = (data["completedAt"] as Timestamp).toDate();
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(
                          data["patientName"] ?? "Unknown Patient",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(data["patientPhone"] ?? ""),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Divider(),

                      _row(
                        Icons.local_hospital,
                        "Hospital",
                        data["hospitalName"] ?? "-",
                      ),

                      _row(
                        Icons.emergency,
                        "Emergency",
                        data["type"] ?? data["emergencyType"] ?? "-",
                      ),

                      _row(
                        Icons.local_shipping,
                        "Ambulance",
                        data["ambulanceNo"] ?? "-",
                      ),

                      _row(
                        Icons.route,
                        "Distance",
                        "${data["distance"] ?? 0} km",
                      ),

                      _row(
                        Icons.timer,
                        "Trip Duration",
                        "${data["tripDuration"] ?? 0} min",
                      ),

                      _row(
                        Icons.currency_rupee,
                        "Fare",
                        "₹${data["fare"] ?? 0}",
                      ),

                      _row(
                        Icons.access_time,
                        "Completed",
                        completedTime == null
                            ? "-"
                            : DateFormat(
                                "dd MMM yyyy, hh:mm a",
                              ).format(completedTime),
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

  Widget _row(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
