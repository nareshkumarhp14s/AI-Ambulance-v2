import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  Future<void> reserveBed(String documentId, int availableBeds) async {
    if (availableBeds <= 0) return;

    await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(documentId)
        .update({'availableBeds': availableBeds - 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Bed Reservation')),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Hospitals Available'));
          }

          final hospitals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),

            itemCount: hospitals.length,

            itemBuilder: (context, index) {
              final hospital = hospitals[index];

              final data = hospital.data() as Map<String, dynamic>;

              final beds = data['availableBeds'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        data['name'] ?? 'Hospital',

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text('Available Beds: $beds'),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: beds <= 0
                              ? null
                              : () async {
                                  await reserveBed(hospital.id, beds);

                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Bed Reserved Successfully',
                                      ),
                                    ),
                                  );
                                },

                          child: const Text('Reserve Bed'),
                        ),
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
