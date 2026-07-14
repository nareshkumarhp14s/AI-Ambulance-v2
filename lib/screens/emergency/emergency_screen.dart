import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Request')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // TITLE
              const Text(
                'Select Emergency Type',

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // EMERGENCY TYPES
              _emergencyCard(Icons.car_crash, 'Road Accident', Colors.red),

              _emergencyCard(Icons.favorite, 'Heart Attack', Colors.pink),

              _emergencyCard(
                Icons.local_fire_department,
                'Fire Emergency',
                Colors.orange,
              ),

              _emergencyCard(
                Icons.health_and_safety,
                'Medical Emergency',
                Colors.green,
              ),

              const SizedBox(height: 35),

              // DESCRIPTION
              const Text(
                'Patient Condition',

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: descriptionController,

                maxLines: 4,

                decoration: InputDecoration(
                  hintText: 'Describe emergency condition...',

                  filled: true,

                  fillColor: Colors.white.withValues(alpha: 0.05),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // VOICE REQUEST CARD
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.5),

                      Colors.blueAccent.withValues(alpha: 0.2),
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
                        'Voice Emergency Request',

                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // REQUEST BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          final currentContext = context;

                          try {
                            final emergencyService = EmergencyService();

                            await emergencyService.sendEmergency(
                              type: selectedEmergency,

                              description: descriptionController.text,
                            );

                            if (!currentContext.mounted) return;

                            showDialog(
                              context: currentContext,

                              builder: (_) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xff1F2937),

                                  title: const Text('Request Sent'),

                                  content: const Text(
                                    'Ambulance request submitted successfully.',
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(currentContext);
                                      },

                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );

                            descriptionController.clear();
                          } catch (e) {
                            if (!currentContext.mounted) return;

                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }

                          if (!mounted) return;

                          setState(() {
                            isLoading = false;
                          });
                        },

                  icon: const Icon(Icons.emergency),

                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Request Ambulance',

                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyCard(IconData icon, String title, Color color) {
    final bool isSelected = selectedEmergency == title;

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
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),

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

              backgroundColor: color.withValues(alpha: 0.2),

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
