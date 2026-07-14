import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequestsScreen extends StatelessWidget {
  const EmergencyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Requests')),

      body: StreamBuilder(
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
            padding: const EdgeInsets.all(20),

            itemCount: requests.length,

            itemBuilder: (context, index) {
              final data = requests[index];

              final docId = requests[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.red,

                          child: Icon(Icons.emergency, color: Colors.white),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            data['type'],

                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        _statusChip(data['status']),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      data['description'],

                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),

                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('emergency_requests')
                                  .doc(docId)
                                  .update({'status': 'dispatched'});
                            },

                            child: const Text('Dispatch'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),

                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('emergency_requests')
                                  .doc(docId)
                                  .update({'status': 'completed'});
                            },

                            child: const Text('Complete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;

    if (status == 'dispatched') {
      color = Colors.blue;
    }

    if (status == 'completed') {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
