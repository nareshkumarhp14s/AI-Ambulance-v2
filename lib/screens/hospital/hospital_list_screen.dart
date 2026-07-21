import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/hospital_service.dart';
import 'hospital_details_screen.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  final HospitalService _hospitalService = HospitalService();

  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Hospitals"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Hospital...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _hospitalService.getHospitals(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hospitals = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name = (data["name"] ?? "").toString().toLowerCase();

                  return name.contains(search);
                }).toList();

                if (hospitals.isEmpty) {
                  return const Center(child: Text("No hospitals found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    final data = hospital.data();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),

                        leading: const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.local_hospital),
                        ),

                        title: Text(
                          data["name"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Speciality: ${data["speciality"] ?? "N/A"}",
                              ),
                              const SizedBox(height: 4),
                              Text("Beds: ${data["availableBeds"] ?? 0}"),
                              const SizedBox(height: 4),
                              Text(data["address"] ?? ""),
                            ],
                          ),
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailsScreen(
                                hospitalId: hospital.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
