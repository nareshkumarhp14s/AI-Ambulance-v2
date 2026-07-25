import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';
import '../booking/booking_status_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool loading = false;

  Future<void> _sendSOS() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final requestId = await EmergencyService().sendEmergency(
        type: "Medical Emergency",
        description: "SOS Request",
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingStatusScreen(requestId: requestId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Emergency"), centerTitle: true),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _sendSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 220),
                  shape: const CircleBorder(),
                ),
                child: const Text(
                  "SOS",
                  style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
