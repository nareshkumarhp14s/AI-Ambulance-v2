import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../tracking/tracking_screen.dart';

class BookingStatusScreen extends StatelessWidget {
  final String requestId;

  const BookingStatusScreen({super.key, required this.requestId});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "searching":
        return Colors.orange;

      case "assigned":
        return Colors.blue;

      case "accepted":
        return Colors.indigo;

      case "arrived":
        return Colors.green;

      case "completed":
        return Colors.teal;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  double getProgress(String status) {
    switch (status.toLowerCase()) {
      case "searching":
        return .2;

      case "assigned":
        return .4;

      case "accepted":
        return .6;

      case "arrived":
        return .8;

      case "completed":
        return 1;

      default:
        return .1;
    }
  }

  String getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case "searching":
        return "Searching Ambulance";

      case "assigned":
        return "Driver Assigned";

      case "accepted":
        return "Ambulance On The Way";

      case "arrived":
        return "Driver Reached";

      case "completed":
        return "Trip Completed";

      case "cancelled":
        return "Request Cancelled";

      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Status"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ambulance_assignments")
            .where("requestId", isEqualTo: requestId)
            .limit(1)
            .snapshots(),
        builder: (context, assignmentSnap) {
          if (assignmentSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!assignmentSnap.hasData || assignmentSnap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Searching for Ambulance...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final assignment =
              assignmentSnap.data!.docs.first.data() as Map<String, dynamic>;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("emergency_requests")
                .doc(requestId)
                .snapshots(),
            builder: (context, requestSnap) {
              if (!requestSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final request =
                  requestSnap.data!.data() as Map<String, dynamic>? ?? {};

              final status = (request["status"] ?? "searching").toString();

              final progress = getProgress(status);

              final statusColor = getStatusColor(status);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getStatusTitle(status),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(20),
                            color: statusColor,
                            backgroundColor: Colors.grey.shade300,
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(Icons.circle, color: statusColor, size: 15),

                              const SizedBox(width: 8),

                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.emergency, color: Colors.white),
                      ),
                      title: Text(
                        request["type"] ?? "Emergency",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        request["description"] ?? "No description",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        assignment["driverName"]?.toString().isNotEmpty == true
                            ? assignment["driverName"]
                            : "Driver Not Assigned",
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(assignment["driverPhone"] ?? "Waiting..."),

                          const SizedBox(height: 5),

                          Text(
                            "Status : ${status.toUpperCase()}",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.local_shipping),
                      ),
                      title: Text(assignment["ambulanceNo"] ?? "Ambulance"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Distance : ${assignment["distance"] ?? "--"} km",
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "ETA : ${request["eta"] ?? assignment["eta"] ?? "--"}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.local_hospital),
                      ),
                      title: Text(request["hospitalName"] ?? "Hospital"),
                      subtitle: Text(
                        request["hospitalAddress"] ??
                            "Hospital information unavailable",
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text(
                        "Track Ambulance",
                        style: TextStyle(fontSize: 17),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrackingScreen(requestId: requestId),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (assignment["driverPhone"] != null &&
                      assignment["driverPhone"].toString().isNotEmpty)
                    SizedBox(
                      height: 55,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.call),
                        label: const Text("Call Driver"),
                        onPressed: () {
                          // Add url_launcher here
                        },
                      ),
                    ),

                  const SizedBox(height: 15),
                  if (status == "searching")
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          "Cancel Request",
                          style: TextStyle(fontSize: 17),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Cancel Request"),
                                content: const Text(
                                  "Are you sure you want to cancel this ambulance request?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("No"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection("emergency_requests")
                                .doc(requestId)
                                .update({
                                  "status": "cancelled",
                                  "cancelledAt": FieldValue.serverTimestamp(),
                                });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Request cancelled successfully",
                                  ),
                                ),
                              );

                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
