import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import 'live_requests_screen.dart';
import 'manage_drivers_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final AdminService adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _countCard(
                    title: "Patients",
                    icon: Icons.people,
                    color: Colors.blue,
                    stream: adminService.patientCount(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _countCard(
                    title: "Drivers",
                    icon: Icons.local_shipping,
                    color: Colors.green,
                    stream: adminService.driverCount(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _countCard(
                    title: "Hospitals",
                    icon: Icons.local_hospital,
                    color: Colors.red,
                    stream: adminService.hospitalCount(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _countCard(
                    title: "Active Trips",
                    icon: Icons.location_on,
                    color: Colors.orange,
                    stream: adminService.activeTripCount(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Admin Menu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Manage Patients"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text("Manage Drivers"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageDriversScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text("Manage Hospitals"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.emergency),
                title: const Text("Live Emergency Requests"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiveRequestsScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text("Analytics"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: StreamBuilder<int>(
          stream: stream,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return Column(
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 10),
                Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title),
              ],
            );
          },
        ),
      ),
    );
  }
}
