import 'package:flutter/material.dart';

import '../../services/driver_location_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverLocationService locationService = DriverLocationService();

  bool tracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 40),

            Icon(
              tracking ? Icons.local_hospital : Icons.location_off,
              size: 120,
              color: Colors.red,
            ),

            const SizedBox(height: 30),

            Text(
              tracking ? 'Trip Active' : 'Trip Not Started',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  locationService.startTracking();

                  setState(() {
                    tracking = true;
                  });
                },

                child: const Text('Start Trip'),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  locationService.stopTracking();

                  setState(() {
                    tracking = false;
                  });
                },

                child: const Text('Stop Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
