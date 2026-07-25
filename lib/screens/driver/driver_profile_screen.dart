import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Driver not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Profile"), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("drivers")
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  child: Icon(Icons.person, size: 55),
                ),

                const SizedBox(height: 20),

                Text(
                  data["name"] ?? "Driver",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(data["email"] ?? user.email ?? ""),

                const SizedBox(height: 25),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(data["phone"] ?? "Not Available"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: const Text("Ambulance Number"),
                    subtitle: Text(data["ambulanceNo"] ?? "Not Assigned"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: const Text("Ambulance Type"),
                    subtitle: Text(data["ambulanceType"] ?? "Not Available"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.circle),
                    title: const Text("Status"),
                    subtitle: Text(data["status"] ?? "Offline"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text("Rating"),
                    subtitle: Text("${data["rating"] ?? 0} ⭐"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text("Total Trips"),
                    subtitle: Text("${data["totalTrips"] ?? 0}"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.gps_fixed),
                    title: const Text("GPS Accuracy"),
                    subtitle: Text("${data["accuracy"] ?? 0} m"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text("Current Speed"),
                    subtitle: Text("${data["speed"] ?? 0} km/h"),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: Icon(
                      (data["online"] ?? false) ? Icons.wifi : Icons.wifi_off,
                      color: (data["online"] ?? false)
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: const Text("Online Status"),
                    subtitle: Text(
                      (data["online"] ?? false) ? "Online" : "Offline",
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
