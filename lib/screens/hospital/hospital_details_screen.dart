import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/hospital_service.dart';

class HospitalDetailsScreen extends StatelessWidget {
  final String hospitalId;

  const HospitalDetailsScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Details")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: HospitalService().getHospital(hospitalId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Hospital not found"));
          }

          final data = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(
                      Icons.local_hospital,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  data["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text("Speciality"),
                    subtitle: Text(data["speciality"] ?? "Not Available"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.hotel),
                    title: const Text("Available Beds"),
                    subtitle: Text("${data["availableBeds"] ?? 0}"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Address"),
                    subtitle: Text(data["address"] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(data["phone"] ?? ""),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bed),
                    label: const Text("Reserve Bed"),
                    onPressed: () async {
                      final success = await HospitalService.reserveBed(
                        hospitalId,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Bed reserved successfully"
                                : "No beds available",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text("Get Directions"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Google Maps integration coming soon."),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text("Call Hospital"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Hospital Phone: ${data["phone"] ?? ""}",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
