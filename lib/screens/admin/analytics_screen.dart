import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedRange = "All Time";

  final List<String> ranges = ["Today", "7 Days", "30 Days", "All Time"];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("ambulance_requests").snapshots(),

      builder: (context, requestSnapshot) {
        if (requestSnapshot.hasError) {
          return Center(child: Text(requestSnapshot.error.toString()));
        }

        if (requestSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!requestSnapshot.hasData) {
          return const Center(child: Text("No request data found"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: firestore.collection("drivers").snapshots(),

          builder: (context, driverSnapshot) {
            if (driverSnapshot.hasError) {
              return Center(child: Text(driverSnapshot.error.toString()));
            }

            if (driverSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!driverSnapshot.hasData) {
              return const Center(child: Text("No driver data found"));
            }

            return StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("hospitals").snapshots(),

              builder: (context, hospitalSnapshot) {
                if (hospitalSnapshot.hasError) {
                  return Center(child: Text(hospitalSnapshot.error.toString()));
                }

                if (hospitalSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (hospitalSnapshot.hasError) {
                  return Center(child: Text(hospitalSnapshot.error.toString()));
                }

                if (hospitalSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!hospitalSnapshot.hasData) {
                  return const Center(child: Text("No hospital data found"));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("users")
                      .where("role", isEqualTo: "patient")
                      .snapshots(),

                  builder: (context, patientSnapshot) {
                    if (patientSnapshot.hasError) {
                      return Center(
                        child: Text(patientSnapshot.error.toString()),
                      );
                    }

                    if (patientSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!patientSnapshot.hasData) {
                      return const Center(child: Text("No patient data found"));
                    }

                    final requests = requestSnapshot.data!.docs;

                    final drivers = driverSnapshot.data!.docs;

                    final hospitals = hospitalSnapshot.data!.docs;

                    final patients = patientSnapshot.data!.docs;

                    return ListView(
                      padding: const EdgeInsets.all(16),

                      children: [
                        Card(
                          elevation: 2,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(20),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Analytics Dashboard",

                                  style: TextStyle(
                                    fontSize: 26,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  "Real-time statistics of the AI Ambulance System",

                                  style: TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 20),

                                DropdownButtonFormField<String>(
                                  value: selectedRange,

                                  decoration: InputDecoration(
                                    labelText: "Date Range",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  items: ranges
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,

                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),

                                  onChanged: (value) {
                                    setState(() {
                                      selectedRange = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        GridView.count(
                          crossAxisCount: 2,

                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 14,

                          mainAxisSpacing: 14,

                          childAspectRatio: 1.25,

                          children: [
                            _buildStatCard(
                              title: "Total Requests",

                              value: requests.length.toString(),

                              icon: Icons.emergency,

                              color: Colors.red,
                            ),

                            _buildStatCard(
                              title: "Completed",

                              value: requests
                                  .where((e) {
                                    final d = e.data() as Map<String, dynamic>;

                                    return d["status"] == "completed";
                                  })
                                  .length
                                  .toString(),

                              icon: Icons.check_circle,

                              color: Colors.green,
                            ),

                            _buildStatCard(
                              title: "Active",

                              value: requests
                                  .where((e) {
                                    final d = e.data() as Map<String, dynamic>;

                                    return d["status"] != "completed" &&
                                        d["status"] != "cancelled";
                                  })
                                  .length
                                  .toString(),

                              icon: Icons.local_shipping,

                              color: Colors.orange,
                            ),

                            _buildStatCard(
                              title: "Cancelled",

                              value: requests
                                  .where((e) {
                                    final d = e.data() as Map<String, dynamic>;

                                    return d["status"] == "cancelled";
                                  })
                                  .length
                                  .toString(),

                              icon: Icons.cancel,

                              color: Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Builder(
                          builder: (_) {
                            final completed = requests.where((e) {
                              final d = e.data() as Map<String, dynamic>;

                              return d["status"] == "completed";
                            }).length;

                            final successRate = requests.isEmpty
                                ? 0
                                : ((completed / requests.length) * 100)
                                      .toStringAsFixed(1);

                            return Card(
                              elevation: 2,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(20),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    const Text(
                                      "Performance",

                                      style: TextStyle(
                                        fontSize: 20,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.trending_up,

                                                color: Colors.green,

                                                size: 36,
                                              ),

                                              const SizedBox(height: 8),

                                              Text(
                                                "$successRate%",

                                                style: const TextStyle(
                                                  fontSize: 24,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              const Text("Success Rate"),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.timer,

                                                color: Colors.blue,

                                                size: 36,
                                              ),

                                              const SizedBox(height: 8),

                                              const Text(
                                                "8 min",

                                                style: TextStyle(
                                                  fontSize: 24,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              const Text("Avg Response"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(20),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Driver Analytics",

                                  style: TextStyle(
                                    fontSize: 20,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                GridView.count(
                                  shrinkWrap: true,

                                  physics: const NeverScrollableScrollPhysics(),

                                  crossAxisCount: 2,

                                  crossAxisSpacing: 14,

                                  mainAxisSpacing: 14,

                                  childAspectRatio: 1.2,

                                  children: [
                                    _buildStatCard(
                                      title: "Total Drivers",

                                      value: drivers.length.toString(),

                                      icon: Icons.people,

                                      color: Colors.indigo,
                                    ),

                                    _buildStatCard(
                                      title: "Online",

                                      value: drivers
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;

                                            return d["online"] == true;
                                          })
                                          .length
                                          .toString(),

                                      icon: Icons.wifi,

                                      color: Colors.green,
                                    ),

                                    _buildStatCard(
                                      title: "Available",

                                      value: drivers
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;

                                            return d["status"] == "available";
                                          })
                                          .length
                                          .toString(),

                                      icon: Icons.check_circle,

                                      color: Colors.blue,
                                    ),

                                    _buildStatCard(
                                      title: "Busy",

                                      value: drivers
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;

                                            return d["status"] == "busy";
                                          })
                                          .length
                                          .toString(),

                                      icon: Icons.local_shipping,

                                      color: Colors.orange,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  "Top Performing Drivers",

                                  style: TextStyle(
                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                ...drivers.take(5).map((driver) {
                                  final data =
                                      driver.data() as Map<String, dynamic>;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),

                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue
                                            .withOpacity(.12),

                                        child: const Icon(Icons.person),
                                      ),

                                      title: Text(data["name"] ?? "Driver"),

                                      subtitle: Text(
                                        "Trips : ${data["totalTrips"] ?? 0}",
                                      ),

                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        children: [
                                          const Icon(
                                            Icons.star,

                                            color: Colors.amber,

                                            size: 18,
                                          ),

                                          Text(
                                            "${data["rating"] ?? 0.0}",

                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hospital Analytics",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.2,
                                  children: [
                                    _buildStatCard(
                                      title: "Hospitals",
                                      value: hospitals.length.toString(),
                                      icon: Icons.local_hospital,
                                      color: Colors.red,
                                    ),

                                    _buildStatCard(
                                      title: "Emergency ON",
                                      value: hospitals
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;
                                            return d["emergencyAvailable"] ==
                                                true;
                                          })
                                          .length
                                          .toString(),
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                    ),

                                    _buildStatCard(
                                      title: "Available Beds",
                                      value: hospitals.fold<int>(0, (sum, e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return sum +
                                            ((d["availableBeds"] ?? 0) as int);
                                      }).toString(),
                                      icon: Icons.bed,
                                      color: Colors.blue,
                                    ),

                                    _buildStatCard(
                                      title: "ICU Beds",
                                      value: hospitals.fold<int>(0, (sum, e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return sum +
                                            ((d["icuBeds"] ?? 0) as int);
                                      }).toString(),
                                      icon: Icons.monitor_heart,
                                      color: Colors.purple,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  "Patient Analytics",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.2,
                                  children: [
                                    _buildStatCard(
                                      title: "Patients",
                                      value: patients.length.toString(),
                                      icon: Icons.people,
                                      color: Colors.indigo,
                                    ),

                                    _buildStatCard(
                                      title: "Active",
                                      value: patients
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;
                                            return d["active"] == true;
                                          })
                                          .length
                                          .toString(),
                                      icon: Icons.person,
                                      color: Colors.green,
                                    ),

                                    _buildStatCard(
                                      title: "Inactive",
                                      value: patients
                                          .where((e) {
                                            final d =
                                                e.data()
                                                    as Map<String, dynamic>;
                                            return d["active"] == false;
                                          })
                                          .length
                                          .toString(),
                                      icon: Icons.block,
                                      color: Colors.red,
                                    ),

                                    _buildStatCard(
                                      title: "Emergency Cases",
                                      value: patients.fold<int>(0, (sum, e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return sum +
                                            ((d["totalEmergencies"] ?? 0)
                                                as int);
                                      }).toString(),
                                      icon: Icons.emergency,
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Top Hospitals",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                ...hospitals.take(5).map((hospital) {
                                  final data =
                                      hospital.data() as Map<String, dynamic>;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.withOpacity(
                                          .1,
                                        ),
                                        child: const Icon(
                                          Icons.local_hospital,
                                          color: Colors.red,
                                        ),
                                      ),
                                      title: Text(
                                        data["hospitalName"] ?? "Hospital",
                                      ),
                                      subtitle: Text(
                                        "Available Beds : ${data["availableBeds"] ?? 0}",
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 18,
                                          ),

                                          Text(
                                            "${data["rating"] ?? 0.0}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 24),

                                const Text(
                                  "System Performance",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                LinearProgressIndicator(
                                  value: requests.isEmpty
                                      ? 0
                                      : requests.where((e) {
                                              final d =
                                                  e.data()
                                                      as Map<String, dynamic>;
                                              return d["status"] == "completed";
                                            }).length /
                                            requests.length,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  "Overall Request Completion",
                                  style: TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  "Emergency Distribution",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildDistributionTile(
                                        "Completed",
                                        requests.where((e) {
                                          final d =
                                              e.data() as Map<String, dynamic>;
                                          return d["status"] == "completed";
                                        }).length,
                                        Colors.green,
                                      ),

                                      const SizedBox(height: 12),

                                      _buildDistributionTile(
                                        "Active",
                                        requests.where((e) {
                                          final d =
                                              e.data() as Map<String, dynamic>;
                                          return d["status"] != "completed" &&
                                              d["status"] != "cancelled";
                                        }).length,
                                        Colors.orange,
                                      ),

                                      const SizedBox(height: 12),

                                      _buildDistributionTile(
                                        "Cancelled",
                                        requests.where((e) {
                                          final d =
                                              e.data() as Map<String, dynamic>;
                                          return d["status"] == "cancelled";
                                        }).length,
                                        Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 34),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionTile(String title, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
