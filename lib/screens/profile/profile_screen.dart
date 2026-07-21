import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/profile_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileService _profileService = ProfileService();

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    context.go('/login');
  }

  Widget buildTile(IconData icon, String title, String value) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value.isEmpty ? "Not Added" : value),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: StreamBuilder(
        stream: _profileService.profileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data = {};

          if (snapshot.hasData && snapshot.data!.data() != null) {
            data = snapshot.data!.data()!;
          }

          final name = data["name"] ?? "Patient";
          final email = data["email"] ?? user?.email ?? "";
          final phone = data["phone"] ?? "";
          final bloodGroup = data["bloodGroup"] ?? "";
          final emergencyContact = data["emergencyContact"] ?? "";
          final photoUrl = data["photoUrl"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: photoUrl != null && photoUrl != ""
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl == ""
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                const SizedBox(height: 20),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(email, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      buildTile(Icons.email, "Email", email),
                      buildTile(Icons.phone, "Phone", phone),
                      buildTile(Icons.bloodtype, "Blood Group", bloodGroup),
                      buildTile(
                        Icons.contact_emergency,
                        "Emergency Contact",
                        emergencyContact,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
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
