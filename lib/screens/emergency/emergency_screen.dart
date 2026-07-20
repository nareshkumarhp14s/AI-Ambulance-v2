import 'package:flutter/material.dart';

import '../../screens/booking/booking_status_screen.dart';
import '../../screens/emergency/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final TextEditingController descriptionController = TextEditingController();

  String selectedEmergency = 'Road Accident';

  bool isLoading = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _requestEmergency() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final emergencyService = EmergencyService();

      final String requestId = await emergencyService.sendEmergency(
        type: selectedEmergency,
        description: descriptionController.text.trim(),
      );

      if (!mounted) return;

      descriptionController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingStatusScreen(requestId: requestId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Request")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Emergency Type",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              _emergencyCard(Icons.car_crash, "Road Accident", Colors.red),

              _emergencyCard(Icons.favorite, "Heart Attack", Colors.pink),

              _emergencyCard(
                Icons.local_fire_department,
                "Fire Emergency",
                Colors.orange,
              ),

              _emergencyCard(
                Icons.health_and_safety,
                "Medical Emergency",
                Colors.green,
              ),

              const SizedBox(height: 35),

              const Text(
                "Patient Condition",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe emergency condition...",
                  filled: true,
                  fillColor: Colors.white.withAlpha(13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withAlpha(120),
                      Colors.blueAccent.withAlpha(60),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mic, size: 45, color: Colors.white),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Voice Emergency Request",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _requestEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.emergency),
                  label: Text(
                    isLoading ? "Sending..." : "Request Ambulance",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyCard(IconData icon, String title, Color color) {
    final isSelected = selectedEmergency == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmergency = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withAlpha(50),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
