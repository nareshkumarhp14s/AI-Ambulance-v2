import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import '../../services/hospital_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool loading = false;

  Future<void> sendSOS() async {
    try {
      print('SOS Pressed');

      await FirebaseFirestore.instance.collection('emergency_requests').add({
        'type': 'SOS',
        'status': 'pending',
        'patientCondition': 'Critical',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('booking_history').add({
        'userId': 'abc123',
        'hospitalName': 'Ranchi Medical Hospital',
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Emergency Request Created');
      print('Booking History Created');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency Request Sent Successfully')),
      );
    } catch (e) {
      print('FIREBASE ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Emergency')),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(250, 250),
                  shape: const CircleBorder(),
                ),
                onPressed: sendSOS,
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
