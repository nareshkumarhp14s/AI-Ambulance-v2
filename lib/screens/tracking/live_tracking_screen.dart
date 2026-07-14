import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? mapController;

  LatLng currentPosition = const LatLng(23.3441, 85.3096);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentPosition, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Ambulance Tracking')),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulance_tracking')
            .doc('v5W71sIR4HJkdfmGVNHq') // YOUR DOCUMENT ID
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No Tracking Data Found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final ambulancePosition = LatLng(
            (data['latitude'] as num).toDouble(),
            (data['longitude'] as num).toDouble(),
          );

          final status = data['status'] ?? 'Unknown';

          final eta = data['eta'] ?? '--';

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentPosition,
                  zoom: 14,
                ),

                myLocationEnabled: true,
                myLocationButtonEnabled: true,

                onMapCreated: (controller) {
                  mapController = controller;
                },

                markers: {
                  Marker(
                    markerId: const MarkerId('user'),

                    position: currentPosition,

                    infoWindow: const InfoWindow(title: 'Your Location'),
                  ),

                  Marker(
                    markerId: const MarkerId('ambulance'),

                    position: ambulancePosition,

                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),

                    infoWindow: const InfoWindow(title: 'Ambulance'),
                  ),
                },

                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),

                    color: Colors.red,
                    width: 5,

                    points: [currentPosition, ambulancePosition],
                  ),
                },
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: 20,

                child: Card(
                  elevation: 6,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Text(
                          'Status: $status',

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text('ETA: $eta', style: const TextStyle(fontSize: 16)),
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
