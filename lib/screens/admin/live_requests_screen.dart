import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LiveRequestsScreen extends StatelessWidget {
  const LiveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Emergency Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("emergency_requests")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No Emergency Requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.emergency)),
                  title: Text(data["patientName"] ?? "Unknown Patient"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Emergency : ${data["emergencyType"] ?? ""}"),
                      Text("Hospital : ${data["hospitalName"] ?? ""}"),
                      Text("Status : ${data["status"] ?? ""}"),
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
