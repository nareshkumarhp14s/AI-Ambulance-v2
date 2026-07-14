import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  Future<void> updateStatus({
    required String documentId,
    required String status,
  }) async {
    await FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(documentId)
        .update({'status': status});
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'dispatched':
        return Colors.blue;

      case 'completed':
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Requests')),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Emergency Requests'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: requests.length,

            itemBuilder: (context, index) {
              final request = requests[index];

              final data = request.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        data['type'] ?? 'Unknown',

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(data['description'] ?? ''),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: getStatusColor(status),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          status.toUpperCase(),

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateStatus(
                                  documentId: request.id,
                                  status: 'dispatched',
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),

                              child: const Text('Dispatch'),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateStatus(
                                  documentId: request.id,
                                  status: 'completed',
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),

                              child: const Text('Complete'),
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
