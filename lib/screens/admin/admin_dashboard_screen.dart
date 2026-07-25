import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const AdminDashboardScreen({super.key, this.onNavigate});

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              "$value",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "searching":
        return Colors.orange;

      case "assigned":
        return Colors.blue;

      case "accepted":
        return Colors.indigo;

      case "en_route":
        return Colors.deepPurple;

      case "arrived":
        return Colors.teal;

      case "picked_up":
        return Colors.cyan;

      case "hospital_reached":
        return Colors.green;

      case "completed":
        return Colors.grey;

      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("emergency_requests").snapshots(),
      builder: (context, emergencySnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection("drivers").snapshots(),
          builder: (context, driverSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("users").snapshots(),
              builder: (context, userSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection("hospitals").snapshots(),
                  builder: (context, hospitalSnap) {
                    if (!emergencySnap.hasData ||
                        !driverSnap.hasData ||
                        !userSnap.hasData ||
                        !hospitalSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final emergencies = emergencySnap.data!.docs;

                    final drivers = driverSnap.data!.docs;

                    final users = userSnap.data!.docs;

                    final hospitals = hospitalSnap.data!.docs;

                    final totalEmergency = emergencies.length;

                    final totalDrivers = drivers.length;

                    final totalHospitals = hospitals.length;

                    final totalPatients = users.where((e) {
                      final data = e.data() as Map<String, dynamic>;

                      return data["role"] == "patient";
                    }).length;

                    final onlineDrivers = drivers.where((e) {
                      final data = e.data() as Map<String, dynamic>;

                      return data["online"] == true;
                    }).length;

                    int availableBeds = 0;

                    int totalBeds = 0;

                    for (final hospital in hospitals) {
                      final data = hospital.data() as Map<String, dynamic>;

                      availableBeds += (data["availableBeds"] ?? 0) as int;

                      totalBeds += (data["totalBeds"] ?? 0) as int;
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Welcome Admin 👋",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    "AI Ambulance Emergency Response System",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  LinearProgressIndicator(
                                    value: totalDrivers == 0
                                        ? 0
                                        : onlineDrivers / totalDrivers,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "$onlineDrivers of $totalDrivers drivers online",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            "System Overview",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.05,
                            children: [
                              _buildStatCard(
                                title: "Emergency",
                                value: totalEmergency,
                                icon: Icons.warning_rounded,
                                color: Colors.red,
                              ),

                              _buildStatCard(
                                title: "Drivers",
                                value: totalDrivers,
                                icon: Icons.local_taxi,
                                color: Colors.blue,
                              ),

                              _buildStatCard(
                                title: "Patients",
                                value: totalPatients,
                                icon: Icons.people,
                                color: Colors.deepPurple,
                              ),

                              _buildStatCard(
                                title: "Hospitals",
                                value: totalHospitals,
                                icon: Icons.local_hospital,
                                color: Colors.green,
                              ),

                              _buildStatCard(
                                title: "Online Drivers",
                                value: onlineDrivers,
                                icon: Icons.wifi,
                                color: Colors.orange,
                              ),

                              _buildStatCard(
                                title: "Available Beds",
                                value: availableBeds,
                                icon: Icons.bed,
                                color: Colors.teal,
                              ),

                              _buildStatCard(
                                title: "Total Beds",
                                value: totalBeds,
                                icon: Icons.hotel,
                                color: Colors.indigo,
                              ),

                              _buildStatCard(
                                title: "Occupancy",
                                value: totalBeds == 0
                                    ? 0
                                    : (((totalBeds - availableBeds) /
                                                  totalBeds) *
                                              100)
                                          .round(),
                                icon: Icons.bar_chart,
                                color: Colors.pink,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.18,
                            children: [
                              _buildQuickAction(
                                title: "Live Requests",
                                icon: Icons.warning,
                                color: Colors.red,
                                onTap: () {
                                  onNavigate?.call(1);
                                },
                              ),

                              _buildQuickAction(
                                title: "Request History",
                                icon: Icons.history,
                                color: Colors.indigo,
                                onTap: () {
                                  onNavigate?.call(2);
                                },
                              ),

                              _buildQuickAction(
                                title: "Drivers",
                                icon: Icons.local_taxi,
                                color: Colors.blue,
                                onTap: () {
                                  onNavigate?.call(3);
                                },
                              ),

                              _buildQuickAction(
                                title: "Patients",
                                icon: Icons.people,
                                color: Colors.deepPurple,
                                onTap: () {
                                  onNavigate?.call(4);
                                },
                              ),

                              _buildQuickAction(
                                title: "Hospitals",
                                icon: Icons.local_hospital,
                                color: Colors.green,
                                onTap: () {
                                  onNavigate?.call(5);
                                },
                              ),

                              _buildQuickAction(
                                title: "Analytics",
                                icon: Icons.analytics,
                                color: Colors.orange,
                                onTap: () {
                                  onNavigate?.call(6);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Recent Emergency Requests",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Text(
                                "${emergencies.length} Total",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          if (emergencies.isEmpty)
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 60,
                                      ),

                                      SizedBox(height: 15),

                                      Text(
                                        "No Active Emergency",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      SizedBox(height: 8),

                                      Text("Everything looks good."),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: emergencies.length > 5
                                  ? 5
                                  : emergencies.length,
                              itemBuilder: (context, index) {
                                final data =
                                    emergencies[index].data()
                                        as Map<String, dynamic>;

                                final status = data["status"] ?? "";

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: _statusColor(
                                                status,
                                              ).withOpacity(.15),
                                              child: Icon(
                                                Icons.warning,
                                                color: _statusColor(status),
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data["patientName"] ??
                                                        "Unknown Patient",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 4),

                                                  Text(
                                                    data["patientPhone"] ?? "",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Chip(
                                              backgroundColor: _statusColor(
                                                status,
                                              ),
                                              label: Text(
                                                status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 18),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_taxi,
                                              size: 20,
                                            ),

                                            const SizedBox(width: 8),

                                            Expanded(
                                              child: Text(
                                                data["driverName"]
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true
                                                    ? data["driverName"]
                                                    : "Driver Not Assigned",
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_hospital,
                                              size: 20,
                                            ),

                                            const SizedBox(width: 8),

                                            Expanded(
                                              child: Text(
                                                data["hospitalName"]
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true
                                                    ? data["hospitalName"]
                                                    : "Hospital Not Assigned",
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            const Icon(Icons.route, size: 20),

                                            const SizedBox(width: 8),

                                            Text(
                                              "${data["distance"] ?? "--"} km",
                                            ),

                                            const Spacer(),

                                            const Icon(Icons.timer, size: 20),

                                            const SizedBox(width: 8),

                                            Text(data["eta"] ?? "--"),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  onNavigate?.call(1);
                                                },
                                                icon: const Icon(
                                                  Icons.visibility,
                                                ),
                                                label: const Text("View"),
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Expanded(
                                              child: FilledButton.icon(
                                                onPressed: () {
                                                  onNavigate?.call(1);
                                                },
                                                icon: const Icon(
                                                  Icons.location_searching,
                                                ),
                                                label: const Text("Track"),
                                              ),
                                            ),
                                          ],
                                        ),

                                        if ((data["bedReserved"] ?? false))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 14,
                                            ),
                                            child: Chip(
                                              avatar: const Icon(
                                                Icons.bed,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.green,
                                              label: const Text(
                                                "BED RESERVED",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 30),

                          const Text(
                            "Recent Activity",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.withOpacity(
                                      .15,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  title: const Text("Completed Trips"),
                                  subtitle: const Text(
                                    "Successfully completed ambulance requests.",
                                  ),
                                  trailing: Text(
                                    emergencies
                                        .where((e) {
                                          final data =
                                              e.data() as Map<String, dynamic>;

                                          return data["status"] == "completed";
                                        })
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.withOpacity(
                                      .15,
                                    ),
                                    child: const Icon(
                                      Icons.local_taxi,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: const Text("Online Drivers"),
                                  subtitle: const Text(
                                    "Drivers available for emergency dispatch.",
                                  ),
                                  trailing: Text(
                                    onlineDrivers.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(
                                      .15,
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: const Text("Hospitals Ready"),
                                  subtitle: const Text(
                                    "Hospitals accepting emergency patients.",
                                  ),
                                  trailing: Text(
                                    hospitals
                                        .where((e) {
                                          final data =
                                              e.data() as Map<String, dynamic>;

                                          return data["emergencyAvailable"] ==
                                              true;
                                        })
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(
                                      .15,
                                    ),
                                    child: const Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: const Text("Pending Emergencies"),
                                  subtitle: const Text(
                                    "Emergency requests awaiting completion.",
                                  ),
                                  trailing: Text(
                                    emergencies
                                        .where((e) {
                                          final data =
                                              e.data() as Map<String, dynamic>;

                                          return data["status"] != "completed";
                                        })
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.green.withOpacity(
                                      .15,
                                    ),
                                    child: const Icon(
                                      Icons.health_and_safety,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                  ),

                                  const SizedBox(width: 18),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "AI Ambulance System",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: 4),

                                        Text(
                                          "Real-time emergency monitoring dashboard",
                                        ),
                                      ],
                                    ),
                                  ),

                                  FilledButton.icon(
                                    onPressed: () {
                                      onNavigate?.call(6);
                                    },
                                    icon: const Icon(Icons.analytics),
                                    label: const Text("Analytics"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
