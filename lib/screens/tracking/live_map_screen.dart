import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? mapController;

  LatLng currentPosition = const LatLng(23.3441, 85.3096);

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
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

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 14,
        ),

        myLocationEnabled: true,

        myLocationButtonEnabled: true,

        zoomControlsEnabled: false,

        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },

        markers: {
          Marker(
            markerId: const MarkerId('user'),

            position: currentPosition,

            infoWindow: const InfoWindow(title: 'Your Location'),
          ),

          const Marker(
            markerId: MarkerId('ambulance'),

            position: LatLng(23.3500, 85.3200),

            infoWindow: InfoWindow(title: 'Ambulance #102'),
          ),
        },
      ),
    );
  }
}
