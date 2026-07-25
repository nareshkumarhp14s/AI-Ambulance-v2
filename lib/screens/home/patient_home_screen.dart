import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../booking/booking_history_screen.dart';
import '../emergency/sos_screen.dart';
import '../profile/profile_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget card(IconData icon, String title, VoidCallback onTap) {
      return Card(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40),
                const SizedBox(height: 10),
                Text(title),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            card(Icons.emergency, "SOS", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SosScreen()),
              );
            }),
            card(Icons.history, "Booking History", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
              );
            }),
            card(Icons.person, "Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            }),
            Card(child: Center(child: Text(user?.email ?? ""))),
          ],
        ),
      ),
    );
  }
}
