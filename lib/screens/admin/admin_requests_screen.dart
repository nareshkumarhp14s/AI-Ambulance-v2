import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String selectedStatus = "all";

  bool newestFirst = true;

  final List<String> statusList = [
    "all",

    "completed",

    "hospital_reached",

    "cancelled",
  ];

  Color statusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green;

      case "hospital_reached":
        return Colors.blue;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case "completed":
        return Icons.check_circle;

      case "hospital_reached":
        return Icons.local_hospital;

      case "cancelled":
        return Icons.cancel;

      default:
        return Icons.history;
    }
  }

  bool matchesSearch(Map<String, dynamic> data) {
    if (searchText.isEmpty) {
      return true;
    }

    final q = searchText.toLowerCase();

    return (data["patientName"] ?? "").toString().toLowerCase().contains(q) ||
        (data["driverName"] ?? "").toString().toLowerCase().contains(q) ||
        (data["hospitalName"] ?? "").toString().toLowerCase().contains(q) ||
        (data["patientPhone"] ?? "").toString().toLowerCase().contains(q);
  }

  bool matchesStatus(Map<String, dynamic> data) {
    if (selectedStatus == "all") {
      return true;
    }

    return data["status"] == selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("emergency_requests").snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No Request History"));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final status = data["status"] ?? "";

          if (status != "completed" &&
              status != "hospital_reached" &&
              status != "cancelled") {
            return false;
          }

          return matchesSearch(data) && matchesStatus(data);
        }).toList();

        docs.sort((a, b) {
          final ad =
              (a.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;

          final bd =
              (b.data() as Map<String, dynamic>)["createdAt"] as Timestamp?;

          if (ad == null || bd == null) {
            return 0;
          }

          if (newestFirst) {
            return bd.compareTo(ad);
          }

          return ad.compareTo(bd);
        });

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
                      "Emergency Request History",

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${docs.length} archived requests",

                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: searchController,

                      decoration: InputDecoration(
                        hintText: "Search patient, driver or hospital",

                        prefixIcon: const Icon(Icons.search),

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
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final status = statusList[index];

                          final selected = selectedStatus == status;

                          return ChoiceChip(
                            label: Text(
                              status == "all"
                                  ? "All"
                                  : status.replaceAll("_", " ").toUpperCase(),
                            ),

                            avatar: Icon(
                              statusIcon(status),

                              size: 18,

                              color: selected
                                  ? Colors.white
                                  : statusColor(status),
                            ),

                            selected: selected,

                            selectedColor: statusColor(status),

                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.black,

                              fontWeight: FontWeight.w600,
                            ),

                            onSelected: (_) {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Text(
                          "Sort",

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(width: 12),

                        ChoiceChip(
                          label: const Text("Newest"),

                          selected: newestFirst,

                          onSelected: (_) {
                            setState(() {
                              newestFirst = true;
                            });
                          },
                        ),

                        const SizedBox(width: 10),

                        ChoiceChip(
                          label: const Text("Oldest"),

                          selected: !newestFirst,

                          onSelected: (_) {
                            setState(() {
                              newestFirst = false;
                            });
                          },
                        ),
                      ],
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
                  padding: EdgeInsets.symmetric(vertical: 70),

                  child: Column(
                    children: [
                      Icon(Icons.history, size: 70, color: Colors.grey),

                      SizedBox(height: 18),

                      Text(
                        "No Request History",

                        style: TextStyle(
                          fontSize: 20,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text("Completed requests will appear here."),
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

                  final status = data["status"] ?? "";

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
                                radius: 25,

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
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      data["patientName"] ?? "Unknown Patient",

                                      style: const TextStyle(
                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,
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
                            children: [
                              const Icon(
                                Icons.local_taxi,
                                size: 20,
                                color: Colors.blue,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  (data["driverName"] ?? "").toString().isEmpty
                                      ? "Driver Not Assigned"
                                      : data["driverName"],
                                ),
                              ),
                            ],
                          ),

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

                          const SizedBox(height: 12),

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
                                      "Pickup address unavailable",
                                ),
                              ),
                            ],
                          ),

                          if ((data["destinationAddress"] ?? "")
                              .toString()
                              .isNotEmpty) ...[
                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.flag,
                                  size: 20,
                                  color: Colors.deepPurple,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(data["destinationAddress"]),
                                ),
                              ],
                            ),
                          ],

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
                                                  .substring(0, 16)
                                            : "--",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (data["completedAt"] != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      "Completed : ${(data["completedAt"] as Timestamp).toDate()}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (data["fare"] != null) ...[
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(Icons.payments, color: Colors.teal),

                                const SizedBox(width: 8),

                                Text(
                                  "Fare : ₹${data["fare"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
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
                                        return SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),

                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  const Text(
                                                    "Emergency Request Details",

                                                    style: TextStyle(
                                                      fontSize: 24,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 24),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.tag,
                                                    ),

                                                    title: const Text(
                                                      "Request ID",
                                                    ),

                                                    subtitle: Text(document.id),
                                                  ),

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

                                                    title: const Text("Status"),

                                                    subtitle: Text(
                                                      status
                                                          .replaceAll("_", " ")
                                                          .toUpperCase(),
                                                    ),
                                                  ),

                                                  if (data["notes"] != null)
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.notes,
                                                      ),

                                                      title: const Text(
                                                        "Notes",
                                                      ),

                                                      subtitle: Text(
                                                        data["notes"],
                                                      ),
                                                    ),

                                                  const SizedBox(height: 20),

                                                  const Divider(),

                                                  const SizedBox(height: 12),

                                                  const Text(
                                                    "Journey Timeline",

                                                    style: TextStyle(
                                                      fontSize: 18,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 18),

                                                  ListTile(
                                                    leading: const CircleAvatar(
                                                      child: Icon(
                                                        Icons.emergency,
                                                      ),
                                                    ),

                                                    title: const Text(
                                                      "Emergency Created",
                                                    ),

                                                    subtitle: Text(
                                                      data["createdAt"] != null
                                                          ? (data["createdAt"]
                                                                    as Timestamp)
                                                                .toDate()
                                                                .toString()
                                                          : "--",
                                                    ),
                                                  ),

                                                  if (data["completedAt"] !=
                                                      null)
                                                    ListTile(
                                                      leading:
                                                          const CircleAvatar(
                                                            child: Icon(
                                                              Icons
                                                                  .check_circle,
                                                            ),
                                                          ),

                                                      title: const Text(
                                                        "Emergency Completed",
                                                      ),

                                                      subtitle: Text(
                                                        (data["completedAt"]
                                                                as Timestamp)
                                                            .toDate()
                                                            .toString(),
                                                      ),
                                                    ),

                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },

                                  icon: const Icon(Icons.visibility),

                                  label: const Text("View Details"),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Export feature coming soon.",
                                        ),
                                      ),
                                    );
                                  },

                                  icon: const Icon(Icons.download),

                                  label: const Text("Export"),
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
            const SizedBox(height: 24),

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
                      "Request Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  docs
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["status"] == "completed";
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Completed"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  docs
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["status"] == "cancelled";
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Cancelled"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.local_hospital,
                                  color: Colors.blue,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  docs
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["status"] ==
                                            "hospital_reached";
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Hospital Reached"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Colors.orange,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  docs.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Total Records"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
