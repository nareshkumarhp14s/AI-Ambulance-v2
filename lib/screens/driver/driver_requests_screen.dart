import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  Future<void> acceptRequest(String assignmentId, String driverId) async {
    await FirebaseFirestore.instance
        .collection('ambulance_assignments')
        .doc(assignmentId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance.collection('drivers').doc(driverId).update(
      {'status': 'busy'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Requests'), centerTitle: true),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulance_assignments')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignments = snapshot.data!.docs;

          if (assignments.isEmpty) {
            return const Center(
              child: Text(
                'No Assignments Found',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            itemCount: assignments.length,

            itemBuilder: (context, index) {
              final assignment =
                  assignments[index].data() as Map<String, dynamic>;

              final assignmentId = assignments[index].id;

              final driverId = assignment['driverId'];

              return Card(
                margin: const EdgeInsets.all(12),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Request ID: ${assignment['requestId']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text('Driver ID: $driverId'),

                      Text('Status: ${assignment['status']}'),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: () async {
                          await acceptRequest(assignmentId, driverId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request Accepted')),
                          );
                        },

                        child: const Text('Accept Request'),
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
