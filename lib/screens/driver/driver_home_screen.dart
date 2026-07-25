import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/services/driver_location_service.dart';
import '../../services/driver_trip_service.dart';
import 'driver_navigation_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _loadingOnline = false;

  Future<void> _changeOnlineStatus(bool value) async {
    if (_loadingOnline) return;

    setState(() {
      _loadingOnline = true;
    });

    try {
      if (value) {
        await DriverLocationService.instance.goOnline();
      } else {
        await DriverLocationService.instance.goOffline();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        _loadingOnline = false;
      });
    }
  }

  Future<void> _logout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (logout != true) return;

    try {
      await DriverLocationService.instance.goOffline();
    } catch (_) {}

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    DriverLocationService.instance.goOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("drivers")
            .doc(uid)
            .snapshots(),
        builder: (context, driverSnapshot) {
          if (driverSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!driverSnapshot.hasData || !driverSnapshot.data!.exists) {
            return const Center(
              child: Text(
                "Driver profile not found.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final driver = driverSnapshot.data!.data() ?? {};

          final bool online = driver["online"] ?? false;

          final String currentAssignment = driver["currentAssignment"] ?? "";

          return RefreshIndicator(
            onRefresh: () async {
              await FirebaseFirestore.instance
                  .collection("drivers")
                  .doc(uid)
                  .get();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      driver["name"] ?? "Driver",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${driver["ambulanceNo"] ?? ""}\n"
                      "${driver["ambulanceType"] ?? ""}",
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  value: online,
                  activeThumbColor: Colors.green,
                  title: const Text(
                    "Online Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    online ? "Receiving Emergency Requests" : "Offline",
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: online ? Colors.green : Colors.grey,
                    child: Icon(
                      online ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  onChanged: _loadingOnline
                      ? null
                      : (value) async {
                          await _changeOnlineStatus(value);
                        },
                ),

                const SizedBox(height: 20),
                if (currentAssignment.isEmpty)
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.local_shipping,
                            size: 65,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "No Active Emergency",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Waiting for emergency requests...",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("ambulance_assignments")
                        .where("requestId", isEqualTo: currentAssignment)
                        .limit(1)
                        .snapshots(),
                    builder: (context, assignmentSnapshot) {
                      if (!assignmentSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (assignmentSnapshot.data!.docs.isEmpty) {
                        return const SizedBox();
                      }

                      final assignment = assignmentSnapshot.data!.docs.first
                          .data();

                      final String status = assignment["status"] ?? "assigned";

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Emergency Assignment",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Divider(),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(assignment["patientName"] ?? ""),
                                subtitle: Text(
                                  assignment["patientPhone"] ?? "",
                                ),
                              ),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.warning),
                                ),
                                title: Text(status.toUpperCase()),
                                subtitle: const Text("Current Status"),
                              ),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.route),
                                ),
                                title: Text(
                                  "${assignment["distance"] ?? 0} km",
                                ),
                                subtitle: Text(assignment["eta"] ?? "--"),
                              ),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.local_hospital),
                                ),
                                title: Text(assignment["hospitalName"] ?? "-"),
                                subtitle: const Text("Assigned Hospital"),
                              ),

                              const SizedBox(height: 20),
                              if (status == "assigned") ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text(
                                      "Accept Request",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .acceptRequest(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.close),
                                    label: const Text("Reject Request"),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .rejectRequest(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),
                              ],

                              if (status == "accepted") ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text(
                                      "Start Trip",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .startTrip(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.phone),
                                    label: const Text("Call Patient"),
                                    onPressed: () {
                                      // TODO:
                                      // url_launcher integration
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    status == "picked_up"
                                        ? Icons.local_hospital
                                        : Icons.navigation,
                                  ),
                                  label: Text(
                                    status == "picked_up"
                                        ? "Navigate to Hospital"
                                        : "Navigate to Patient",
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DriverNavigationScreen(
                                          requestId: currentAssignment,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (status == "en_route") ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.location_on),
                                    label: const Text(
                                      "Arrived At Patient",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .arriveAtPatient(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),
                              ],

                              if (status == "arrived") ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.medical_services),
                                    label: const Text(
                                      "Pickup Patient",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .pickupPatient(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),
                              ],

                              if (status == "picked_up") ...[
                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.local_hospital),
                                    label: const Text(
                                      "Reached Hospital",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .reachHospital(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),
                              ],

                              if (status == "hospital_reached") ...[
                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.done_all),
                                    label: const Text(
                                      "Complete Trip",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      await DriverTripService.instance
                                          .completeTrip(
                                            requestId: currentAssignment,
                                            driverId: uid,
                                          );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _card(
                      "Trips",
                      "${driver["totalTrips"] ?? 0}",
                      Icons.history,
                    ),

                    _card("Rating", "${driver["rating"] ?? 0}", Icons.star),

                    _card(
                      "Speed",
                      "${((driver["speed"] ?? 0) * 3.6).toStringAsFixed(1)} km/h",
                      Icons.speed,
                    ),

                    _card(
                      "Accuracy",
                      "${driver["accuracy"] ?? 0} m",
                      Icons.gps_fixed,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      online ? Icons.check_circle : Icons.cancel,
                      color: online ? Colors.green : Colors.red,
                    ),
                    title: const Text("Driver Status"),
                    subtitle: Text(driver["status"] ?? "offline"),
                    trailing: Chip(
                      label: Text(online ? "ONLINE" : "OFFLINE"),
                      backgroundColor: online
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                    ),
                  ),
                ),

                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text("Current Assignment"),
                    subtitle: Text(
                      currentAssignment.isEmpty
                          ? "No Active Assignment"
                          : currentAssignment,
                    ),
                    trailing: currentAssignment.isEmpty
                        ? const Icon(Icons.hourglass_empty, color: Colors.grey)
                        : const Icon(Icons.local_shipping, color: Colors.green),
                  ),
                ),

                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Last Location Update"),
                    subtitle: Text(
                      driver["lastUpdated"] == null
                          ? "--"
                          : driver["lastUpdated"].toDate().toString(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return SizedBox(
      width: 170,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.red),

              const SizedBox(height: 10),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
