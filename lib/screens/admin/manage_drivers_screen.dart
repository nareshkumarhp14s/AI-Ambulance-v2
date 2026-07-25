import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageDriversScreen extends StatefulWidget {
  const ManageDriversScreen({super.key});

  @override
  State<ManageDriversScreen> createState() => _ManageDriversScreenState();
}

class _ManageDriversScreenState extends State<ManageDriversScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String onlineFilter = "all";

  String availabilityFilter = "all";

  Color onlineColor(bool online) {
    return online ? Colors.green : Colors.grey;
  }

  bool matchSearch(Map<String, dynamic> data) {
    if (searchText.isEmpty) {
      return true;
    }

    final q = searchText.toLowerCase();

    return (data["name"] ?? "").toString().toLowerCase().contains(q) ||
        (data["phone"] ?? "").toString().toLowerCase().contains(q) ||
        (data["vehicleNumber"] ?? "").toString().toLowerCase().contains(q);
  }

  bool matchOnline(Map<String, dynamic> data) {
    if (onlineFilter == "all") {
      return true;
    }

    if (onlineFilter == "online") {
      return data["online"] == true;
    }

    return data["online"] == false;
  }

  bool matchAvailability(Map<String, dynamic> data) {
    if (availabilityFilter == "all") {
      return true;
    }

    return data["status"] == availabilityFilter;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("drivers").snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No Drivers Found"));
        }

        List<QueryDocumentSnapshot> drivers = snapshot.data!.docs;

        drivers = drivers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return matchSearch(data) &&
              matchOnline(data) &&
              matchAvailability(data);
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
                      "Manage Drivers",

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${drivers.length} registered drivers",

                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: searchController,

                      decoration: InputDecoration(
                        hintText: "Search driver, phone or vehicle",

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

                    const SizedBox(height: 18),
                    const Text(
                      "Online Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: onlineFilter == "all",
                          onSelected: (_) {
                            setState(() {
                              onlineFilter = "all";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Online"),
                          selected: onlineFilter == "online",
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: onlineFilter == "online"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              onlineFilter = "online";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Offline"),
                          selected: onlineFilter == "offline",
                          selectedColor: Colors.grey,
                          labelStyle: TextStyle(
                            color: onlineFilter == "offline"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              onlineFilter = "offline";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Availability",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: availabilityFilter == "all",
                          onSelected: (_) {
                            setState(() {
                              availabilityFilter = "all";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Available"),
                          selected: availabilityFilter == "available",
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: availabilityFilter == "available"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              availabilityFilter = "available";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Busy"),
                          selected: availabilityFilter == "busy",
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: availabilityFilter == "busy"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              availabilityFilter = "busy";
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

            if (drivers.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    children: [
                      Icon(Icons.local_taxi, size: 70, color: Colors.grey),

                      SizedBox(height: 16),

                      Text(
                        "No Driver Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text("Try changing your filters."),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: drivers.length,

                itemBuilder: (context, index) {
                  final document = drivers[index];

                  final data = document.data() as Map<String, dynamic>;

                  final online = data["online"] ?? false;

                  final available = data["status"] == "available";

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
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,

                                    child: Text(
                                      (data["name"] ?? "D")
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),

                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    right: 0,

                                    bottom: 0,

                                    child: Container(
                                      width: 16,

                                      height: 16,

                                      decoration: BoxDecoration(
                                        color: onlineColor(online),

                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),

                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data["name"] ?? "Unknown Driver",

                                            style: const TextStyle(
                                              fontSize: 18,

                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        if (data["verified"] == true)
                                          const Icon(
                                            Icons.verified,

                                            color: Colors.blue,
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      data["phone"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Chip(
                                backgroundColor: available
                                    ? Colors.green
                                    : Colors.red,
                                label: Text(
                                  available ? "AVAILABLE" : "BUSY",
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
                                Icons.directions_car,
                                color: Colors.indigo,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  data["vehicleNumber"] ??
                                      "Vehicle Number Not Available",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping,
                                color: Colors.deepPurple,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(data["vehicleType"] ?? "Ambulance"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.badge,
                                color: Colors.orange,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  data["licenseNumber"] ??
                                      "License Not Available",
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
                                        Icons.star,
                                        color: Colors.amber,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Rating",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["rating"] ?? 0.0}",
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
                                        Icons.route,
                                        color: Colors.green,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Trips",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["totalTrips"] ?? 0}",
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
                                        Icons.work_history,
                                        color: Colors.blue,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Experience",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["experience"] ?? 0} yrs",
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

                          if (data["currentLocation"] != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    data["currentLocation"].toString(),
                                  ),
                                ),
                              ],
                            ),

                          if (data["joinedAt"] != null) ...[
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.teal,
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    "Joined : ${(data["joinedAt"] as Timestamp).toDate().toString().substring(0, 10)}",
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

                                                children: [
                                                  const Text(
                                                    "Driver Details",

                                                    style: TextStyle(
                                                      fontSize: 24,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 24),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.person,
                                                    ),

                                                    title: const Text("Driver"),

                                                    subtitle: Text(
                                                      data["name"] ?? "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.phone,
                                                    ),

                                                    title: const Text("Phone"),

                                                    subtitle: Text(
                                                      data["phone"] ?? "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.badge,
                                                    ),

                                                    title: const Text(
                                                      "License",
                                                    ),

                                                    subtitle: Text(
                                                      data["licenseNumber"] ??
                                                          "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.directions_car,
                                                    ),

                                                    title: const Text(
                                                      "Vehicle",
                                                    ),

                                                    subtitle: Text(
                                                      data["vehicleNumber"] ??
                                                          "--",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.star,
                                                    ),

                                                    title: const Text("Rating"),

                                                    subtitle: Text(
                                                      "${data["rating"] ?? 0.0}",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.route,
                                                    ),

                                                    title: const Text("Trips"),

                                                    subtitle: Text(
                                                      "${data["totalTrips"] ?? 0}",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.info,
                                                    ),

                                                    title: const Text("Status"),

                                                    subtitle: Text(
                                                      data["status"] ??
                                                          "Unknown",
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.circle,
                                                    ),

                                                    title: const Text("Online"),

                                                    subtitle: Text(
                                                      online
                                                          ? "Online"
                                                          : "Offline",
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),
                                                ],
                                              ),
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

                              const SizedBox(width: 12),

                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    await firestore
                                        .collection("drivers")
                                        .doc(document.id)
                                        .update({"online": !online});
                                  },

                                  icon: Icon(
                                    online
                                        ? Icons.power_settings_new
                                        : Icons.wifi,
                                  ),

                                  label: Text(
                                    online ? "Go Offline" : "Go Online",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: available
                                        ? Colors.orange
                                        : Colors.green,
                                  ),

                                  onPressed: () async {
                                    await firestore
                                        .collection("drivers")
                                        .doc(document.id)
                                        .update({
                                          "status": available
                                              ? "busy"
                                              : "available",
                                        });
                                  },

                                  icon: Icon(
                                    available
                                        ? Icons.pause_circle
                                        : Icons.check_circle,
                                  ),

                                  label: Text(
                                    available ? "Mark Busy" : "Mark Available",
                                  ),
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
                      "Driver Summary",
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
                              color: Colors.blue.withOpacity(.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Colors.blue,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  drivers.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Total Drivers"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

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
                                  Icons.wifi,
                                  color: Colors.green,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  drivers
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["online"] == true;
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Online"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
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
                                  Icons.check_circle,
                                  color: Colors.orange,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  drivers
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["status"] == "available";
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Available"),
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
                                  Icons.pause_circle,
                                  color: Colors.red,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  drivers
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["status"] == "busy";
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Busy"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.indigo),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Verified Drivers : ${drivers.where((e) {
                                final d = e.data() as Map<String, dynamic>;
                                return d["verified"] == true;
                              }).length}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
