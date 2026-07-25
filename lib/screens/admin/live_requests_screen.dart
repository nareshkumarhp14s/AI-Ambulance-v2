import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LiveRequestsScreen extends StatefulWidget {
  const LiveRequestsScreen({super.key});

  @override
  State<LiveRequestsScreen> createState() => _LiveRequestsScreenState();
}

class _LiveRequestsScreenState extends State<LiveRequestsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String selectedStatus = "all";

  final List<String> statusList = [
    "all",
    "searching",
    "assigned",
    "accepted",
    "en_route",
    "arrived",
    "picked_up",
  ];

  Color statusColor(String status) {
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
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case "searching":
        return Icons.search;

      case "assigned":
        return Icons.local_taxi;

      case "accepted":
        return Icons.check_circle;

      case "en_route":
        return Icons.route;

      case "arrived":
        return Icons.location_on;

      case "picked_up":
        return Icons.health_and_safety;

      default:
        return Icons.warning;
    }
  }

  bool matchesSearch(Map<String, dynamic> data) {
    if (searchText.isEmpty) {
      return true;
    }

    final query = searchText.toLowerCase();

    return (data["patientName"] ?? "").toString().toLowerCase().contains(
          query,
        ) ||
        (data["patientPhone"] ?? "").toString().toLowerCase().contains(query) ||
        (data["driverName"] ?? "").toString().toLowerCase().contains(query) ||
        (data["hospitalName"] ?? "").toString().toLowerCase().contains(query);
  }

  bool matchesStatus(Map<String, dynamic> data) {
    if (selectedStatus == "all") {
      return true;
    }

    return data["status"] == selectedStatus;
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,

      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("emergency_requests")
            .where(
              "status",
              whereIn: [
                "searching",
                "assigned",
                "accepted",
                "en_route",
                "arrived",
                "picked_up",
              ],
            )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Live Requests"));
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return matchesSearch(data) && matchesStatus(data);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),

            children: [
              Card(
                elevation: 2,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Live Emergency Requests",

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${docs.length} active emergencies",

                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: searchController,

                        decoration: InputDecoration(
                          hintText: "Search patient, driver or hospital",

                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: searchText.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = "";
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: statusList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final status = statusList[index];

                            final selected = selectedStatus == status;

                            return ChoiceChip(
                              label: Text(
                                status == "all"
                                    ? "All"
                                    : status.replaceAll("_", " ").toUpperCase(),
                              ),
                              selected: selected,
                              avatar: Icon(
                                statusIcon(status),
                                size: 18,
                                color: selected
                                    ? Colors.white
                                    : statusColor(status),
                              ),
                              selectedColor: statusColor(status),
                              onSelected: (_) {
                                setState(() {
                                  selectedStatus = status;
                                });
                              },
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (docs.isEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 70, color: Colors.green),

                        SizedBox(height: 16),

                        Text(
                          "No Active Emergency",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text("There are currently no live requests."),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final document = docs[index];

                    final data = document.data() as Map<String, dynamic>;

                    final status = data["status"] ?? "searching";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),

                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,

                                  backgroundColor: statusColor(
                                    status,
                                  ).withOpacity(.15),

                                  child: Icon(
                                    statusIcon(status),

                                    color: statusColor(status),
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
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
                                  backgroundColor: statusColor(status),

                                  label: Text(
                                    status.replaceAll("_", " ").toUpperCase(),

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.red,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    data["pickupAddress"] ??
                                        data["address"] ??
                                        "Location not available",
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(
                                  Icons.local_taxi,
                                  size: 20,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    (data["driverName"] ?? "")
                                            .toString()
                                            .isEmpty
                                        ? "Driver Not Assigned"
                                        : data["driverName"],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            if ((data["ambulanceNumber"] ?? "")
                                .toString()
                                .isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_car,
                                    size: 20,
                                    color: Colors.indigo,
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(data["ambulanceNumber"]),
                                  ),
                                ],
                              ),

                            if ((data["ambulanceNumber"] ?? "")
                                .toString()
                                .isNotEmpty)
                              const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(
                                  Icons.local_hospital,
                                  size: 20,
                                  color: Colors.green,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    (data["hospitalName"] ?? "")
                                            .toString()
                                            .isEmpty
                                        ? "Hospital Not Assigned"
                                        : data["hospitalName"],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.route,
                                          color: Colors.orange,
                                        ),

                                        const SizedBox(height: 6),

                                        const Text(
                                          "Distance",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "${data["distance"] ?? "--"} km",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.timer,
                                          color: Colors.red,
                                        ),

                                        const SizedBox(height: 6),

                                        const Text(
                                          "ETA",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          data["eta"] ?? "--",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.blue,
                                        ),

                                        const SizedBox(height: 6),

                                        const Text(
                                          "Created",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          data["createdAt"] != null
                                              ? (data["createdAt"] as Timestamp)
                                                    .toDate()
                                                    .toString()
                                                    .substring(11, 16)
                                              : "--",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Live tracking will open here.",
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.location_searching),
                                    label: const Text("Track"),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (_) {
                                          return Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "Emergency Details",
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.person,
                                                    ),
                                                    title: const Text(
                                                      "Patient",
                                                    ),
                                                    subtitle: Text(
                                                      data["patientName"] ??
                                                          "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.phone,
                                                    ),
                                                    title: const Text("Phone"),
                                                    subtitle: Text(
                                                      data["patientPhone"] ??
                                                          "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.local_taxi,
                                                    ),
                                                    title: const Text("Driver"),
                                                    subtitle: Text(
                                                      data["driverName"] ??
                                                          "Not Assigned",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.local_hospital,
                                                    ),
                                                    title: const Text(
                                                      "Hospital",
                                                    ),
                                                    subtitle: Text(
                                                      data["hospitalName"] ??
                                                          "Not Assigned",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.info,
                                                    ),
                                                    title: const Text(
                                                      "Current Status",
                                                    ),
                                                    subtitle: Text(
                                                      status
                                                          .replaceAll("_", " ")
                                                          .toUpperCase(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text("Details"),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if ((data["bedReserved"] ?? false))
                              Align(
                                alignment: Alignment.centerLeft,
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

                            if ((data["priority"] ?? "")
                                    .toString()
                                    .toLowerCase() ==
                                "critical")
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red),

                                      SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          "Critical Emergency - Immediate attention required.",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
