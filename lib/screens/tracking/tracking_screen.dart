import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatelessWidget {
  final String requestId;

  const TrackingScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Ambulance Tracking"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ambulance_tracking")
            .doc(requestId)
            .snapshots(),
        builder: (context, trackingSnapshot) {
          if (trackingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (trackingSnapshot.hasError) {
            return Center(child: Text(trackingSnapshot.error.toString()));
          }

          if (!trackingSnapshot.hasData || !trackingSnapshot.data!.exists) {
            return const Center(
              child: Text("Waiting for ambulance location..."),
            );
          }

          final tracking =
              trackingSnapshot.data!.data() as Map<String, dynamic>;

          final double latitude =
              (tracking["latitude"] as num?)?.toDouble() ?? 0.0;

          final double longitude =
              (tracking["longitude"] as num?)?.toDouble() ?? 0.0;

          final String status = tracking["status"] ?? "Searching";

          final String driverId = tracking["driverId"] ?? "";

          final LatLng ambulance = LatLng(latitude, longitude);

          return Column(
            children: [
              Expanded(
                flex: 3,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: ambulance,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("ambulance"),
                      position: ambulance,
                      infoWindow: const InfoWindow(title: "Ambulance"),
                    ),
                  },
                ),
              ),

              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("drivers")
                        .doc(driverId)
                        .snapshots(),
                    builder: (context, driverSnapshot) {
                      String driverName = "Waiting...";
                      String phone = "";

                      if (driverSnapshot.hasData &&
                          driverSnapshot.data!.exists) {
                        final driver =
                            driverSnapshot.data!.data() as Map<String, dynamic>;

                        driverName = driver["name"] ?? "Driver";

                        phone = driver["phone"] ?? "";
                      }

                      return Column(
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.local_hospital,
                                color: Colors.red,
                              ),
                              title: Text(status.toUpperCase()),
                              subtitle: const Text("Ambulance Status"),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                              title: Text(driverName),
                              subtitle: Text(phone),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              title: Text(
                                "Lat : ${latitude.toStringAsFixed(6)}",
                              ),
                              subtitle: Text(
                                "Lng : ${longitude.toStringAsFixed(6)}",
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
