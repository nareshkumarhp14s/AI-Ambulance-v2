import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../profile/profile_screen.dart';

import 'admin_dashboard_screen.dart';
import 'admin_requests_screen.dart';
import 'analytics_screen.dart';
import 'live_requests_screen.dart';
import 'manage_drivers_screen.dart';
import 'manage_hospitals_screen.dart';
import 'manage_patients_screen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int selectedIndex = 0;

  final List<String> titles = const [
    "Dashboard",
    "Live Requests",
    "Request History",
    "Driver Management",
    "Patient Management",
    "Hospital Management",
    "Analytics",
    "Profile",
  ];

  late final List<Widget> pages = [
    AdminDashboardScreen(onNavigate: changePage),
    const LiveRequestsScreen(),
    const AdminRequestsScreen(),
    const ManageDriversScreen(),
    const ManagePatientsScreen(),
    const ManageHospitalsScreen(),
    const AnalyticsScreen(),
    ProfileScreen(),
  ];

  void changePage(int index) {
    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);

    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you really want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    context.go("/login");
  }

  Widget drawerTile({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      selected: selectedIndex == index,
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        setState(() {
          selectedIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[selectedIndex]), centerTitle: true),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.admin_panel_settings, size: 40),
                ),
                accountName: const Text(
                  "Administrator",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  FirebaseAuth.instance.currentUser?.email ?? "admin@email.com",
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    drawerTile(
                      icon: Icons.dashboard_rounded,
                      title: "Dashboard",
                      index: 0,
                    ),

                    const Divider(),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "EMERGENCY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    drawerTile(
                      icon: Icons.warning_amber_rounded,
                      title: "Live Requests",
                      index: 1,
                    ),

                    drawerTile(
                      icon: Icons.history,
                      title: "Request History",
                      index: 2,
                    ),

                    const Divider(),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "MANAGEMENT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    drawerTile(
                      icon: Icons.local_taxi,
                      title: "Driver Management",
                      index: 3,
                    ),

                    drawerTile(
                      icon: Icons.people_alt_rounded,
                      title: "Patient Management",
                      index: 4,
                    ),

                    drawerTile(
                      icon: Icons.local_hospital,
                      title: "Hospital Management",
                      index: 5,
                    ),

                    const Divider(),

                    drawerTile(
                      icon: Icons.analytics_outlined,
                      title: "Analytics",
                      index: 6,
                    ),

                    drawerTile(
                      icon: Icons.person_outline,
                      title: "Profile",
                      index: 7,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: logout,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      body: IndexedStack(index: selectedIndex, children: pages),
    );
  }
}
