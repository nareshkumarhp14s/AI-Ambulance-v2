import 'package:flutter/material.dart';

import '../ai_assistant/ai_assistant_screen.dart';
import '../booking/booking_history_screen.dart';
import '../emergency/emergency_screen.dart';
import '../hospital/hospital_screen.dart';
import '../tracking/tracking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Ambulance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),

                    SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Current Location",
                            style: TextStyle(color: Colors.grey),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Ranchi, Jharkhand",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
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
                          color: Colors.red.withValues(alpha: .40),

                          blurRadius: 35,

                          spreadRadius: 5,
                        ),
                      ],
                    ),

                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(Icons.sos, color: Colors.white, size: 70),

                        SizedBox(height: 10),

                        Text(
                          "SOS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Request Ambulance",
                          style: TextStyle(color: Colors.white),
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

                    title: "Tracking",

                    icon: Icons.location_searching,

                    color: Colors.orange,

                    screen: const TrackingScreen(),
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

                    title: "History",

                    icon: Icons.history,

                    color: Colors.purple,

                    screen: const BookingHistoryScreen(),
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
                  color: Colors.amber.shade100,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),

                        SizedBox(width: 10),

                        Text(
                          "Emergency Tips",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

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

              const SizedBox(height: 30),
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
    required Widget screen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
              child: Icon(icon, color: Colors.white, size: 30),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
