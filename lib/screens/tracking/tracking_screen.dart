import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Ambulance Tracking'),
        centerTitle: true,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulance_tracking')
            .doc('Xc5xkWVL9wHMi5Zjj9TO')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Ambulance document does not exist'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String status = data['status']?.toString() ?? 'Unknown';

          final String eta = data['eta']?.toString() ?? 'N/A';

          final double latitude = (data['latitude'] as num).toDouble();

          final double longitude = (data['longitude'] as num).toDouble();

          final LatLng ambulanceLocation = LatLng(latitude, longitude);

          return Column(
            children: [
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: ambulanceLocation,
                    zoom: 18,
                  ),

                  markers: {
                    Marker(
                      markerId: const MarkerId('ambulance'),
                      position: ambulanceLocation,
                      infoWindow: const InfoWindow(title: 'Ambulance'),
                    ),
                  },
                ),
              ),

              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                          ),

                          title: Text(status.toUpperCase()),

                          subtitle: Text('ETA: $eta'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),

                          title: Text('Latitude: $latitude'),

                          subtitle: Text('Longitude: $longitude'),
                        ),
                      ),
                    ],
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
