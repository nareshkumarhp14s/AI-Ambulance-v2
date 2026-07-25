import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../notification_screen.dart';
import '../../services/map_service.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../booking/booking_history_screen.dart';
import '../emergency/emergency_screen.dart';
import '../hospital/hospital_screen.dart';
import '../booking/booking_status_screen.dart';
import '../tracking/tracking_screen.dart';
import '../../services/patient_booking_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = "Fetching location...";
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _openTracking() async {
    final requestId = await PatientBookingService.instance.getActiveRequestId();

    if (!mounted) return;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active ambulance request found.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackingScreen(requestId: requestId)),
    );
  }

  Future<void> _openBookingStatus() async {
    final requestId = await PatientBookingService.instance.getActiveRequestId();

    if (!mounted) return;

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active ambulance request found.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingStatusScreen(requestId: requestId),
      ),
    );
  }

  Future<void> _loadLocation() async {
    try {
      final Position position = await MapService.instance.getCurrentLocation();

      final address = await MapService.instance.getAddress(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _location = address.isEmpty
            ? "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}"
            : address;
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _location = "Location unavailable";
        _loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Ambulance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 43, 44, 72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Location",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          _loadingLocation
                              ? const Text(
                                  "Fetching location...",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                )
                              : Text(
                                  _location,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadLocation,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmergencyScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: .35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SOS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 65,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Tap to Request Ambulance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Quick Services",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                  _serviceCard(
                    context,
                    title: "Hospital",
                    icon: Icons.local_hospital,
                    color: Colors.green,
                    screen: const HospitalScreen(),
                  ),

                  _serviceCard(
                    context,
                    title: "AI Assistant",
                    icon: Icons.smart_toy,
                    color: Colors.blue,
                    screen: const AiAssistantScreen(),
                  ),

                  _serviceCard(
                    context,
                    title: "Booking Status",
                    icon: Icons.assignment,
                    color: Colors.orange,
                    onTap: _openBookingStatus,
                  ),

                  _serviceCard(
                    context,
                    title: "History",
                    icon: Icons.history,
                    color: Colors.purple,
                    screen: const BookingHistoryScreen(),
                  ),

                  _serviceCard(
                    context,
                    title: "Live Tracking",
                    icon: Icons.location_searching,
                    color: Colors.red,
                    onTap: _openTracking,
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text(
                "Emergency Tips",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 40, 50, 81),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Stay calm."),
                    SizedBox(height: 8),
                    Text("• Share your live location."),
                    SizedBox(height: 8),
                    Text("• Keep your phone charged."),
                    SizedBox(height: 8),
                    Text("• Follow AI guidance until ambulance arrives."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    Widget? screen,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (onTap != null) {
          onTap();
          return;
        }

        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
