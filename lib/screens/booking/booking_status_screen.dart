import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingStatusScreen extends StatelessWidget {
  final String requestId;

  const BookingStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Status'), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // Ambulance Status
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ambulance_tracking')
                  .doc('Xc5xkWVL9wHMi5Zjj9TO')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_hospital,
                      color: Colors.red,
                    ),
                    title: Text('Ambulance: ${data['status']}'),
                    subtitle: Text('ETA: ${data['eta']}'),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Driver Assignment
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ambulance_assignments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    child: ListTile(title: Text('No Driver Assigned')),
                  );
                }

                final assignment =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text('Driver ID: ${assignment['driverId']}'),
                    subtitle: Text('Status: ${assignment['status']}'),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Hospital Status
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hospitals')
                  .doc('hospital_1')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final hospital = snapshot.data!.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_hospital,
                      color: Colors.green,
                    ),
                    title: Text(hospital['name']),
                    subtitle: Text(
                      'Available Beds: ${hospital['availableBeds']}',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'Your ambulance request is being processed. Track driver, ambulance status and hospital availability here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
