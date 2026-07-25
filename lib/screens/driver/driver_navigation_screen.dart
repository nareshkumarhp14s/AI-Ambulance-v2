import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverNavigationScreen extends StatelessWidget {
  final String requestId;

  const DriverNavigationScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Navigation"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ambulance_assignments")
            .where("requestId", isEqualTo: requestId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final pickup = LatLng(
            (data["pickupLatitude"] as num).toDouble(),
            (data["pickupLongitude"] as num).toDouble(),
          );
          final status = data["status"] ?? "";

          final destination = LatLng(
            ((data["destinationLatitude"] ?? data["pickupLatitude"]) as num)
                .toDouble(),
            ((data["destinationLongitude"] ?? data["pickupLongitude"]) as num)
                .toDouble(),
          );

          final bool goHospital =
              status == "picked_up" || status == "hospital_reached";

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: goHospital ? destination : pickup,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(goHospital ? "hospital" : "pickup"),
                    position: goHospital ? destination : pickup,
                    infoWindow: InfoWindow(
                      title: goHospital ? "Hospital" : "Patient",
                    ),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Patient: ${data["patientName"] ?? ""}"),
                        Text("Phone: ${data["patientPhone"] ?? ""}"),
                        Text("Hospital: ${data["hospitalName"] ?? ""}"),
                        Text("Status: ${data["status"] ?? ""}"),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
