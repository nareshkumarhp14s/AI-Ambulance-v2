import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageHospitalsScreen extends StatefulWidget {
  const ManageHospitalsScreen({super.key});

  @override
  State<ManageHospitalsScreen> createState() => _ManageHospitalsScreenState();
}

class _ManageHospitalsScreenState extends State<ManageHospitalsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String emergencyFilter = "all";

  bool hasBedsOnly = false;

  bool matchSearch(Map<String, dynamic> data) {
    if (searchText.isEmpty) {
      return true;
    }

    final q = searchText.toLowerCase();

    return (data["hospitalName"] ?? "").toString().toLowerCase().contains(q) ||
        (data["address"] ?? "").toString().toLowerCase().contains(q) ||
        (data["phone"] ?? "").toString().toLowerCase().contains(q);
  }

  bool matchEmergency(Map<String, dynamic> data) {
    if (emergencyFilter == "all") {
      return true;
    }

    if (emergencyFilter == "available") {
      return data["emergencyAvailable"] == true;
    }

    return data["emergencyAvailable"] == false;
  }

  bool matchBeds(Map<String, dynamic> data) {
    if (!hasBedsOnly) {
      return true;
    }

    return (data["availableBeds"] ?? 0) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("hospitals").snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No Hospitals Found"));
        }

        List<QueryDocumentSnapshot> hospitals = snapshot.data!.docs;

        hospitals = hospitals.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return matchSearch(data) && matchEmergency(data) && matchBeds(data);
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
                      "Manage Hospitals",

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${hospitals.length} registered hospitals",

                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: searchController,

                      decoration: InputDecoration(
                        hintText: "Search hospital, address or phone",

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
                      "Emergency Service",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: emergencyFilter == "all",
                          onSelected: (_) {
                            setState(() {
                              emergencyFilter = "all";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Available"),
                          selected: emergencyFilter == "available",
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: emergencyFilter == "available"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              emergencyFilter = "available";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Unavailable"),
                          selected: emergencyFilter == "unavailable",
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: emergencyFilter == "unavailable"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              emergencyFilter = "unavailable";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,

                      title: const Text(
                        "Show Hospitals With Available Beds Only",
                      ),

                      value: hasBedsOnly,

                      onChanged: (value) {
                        setState(() {
                          hasBedsOnly = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (hospitals.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),

                  child: Column(
                    children: [
                      Icon(Icons.local_hospital, size: 70, color: Colors.grey),

                      SizedBox(height: 16),

                      Text(
                        "No Hospitals Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text("Try changing the filters."),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: hospitals.length,

                itemBuilder: (context, index) {
                  final document = hospitals[index];

                  final data = document.data() as Map<String, dynamic>;

                  final emergency = data["emergencyAvailable"] ?? false;

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
                                radius: 30,

                                backgroundColor: Colors.red.withOpacity(.12),

                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      data["hospitalName"] ??
                                          "Unknown Hospital",

                                      style: const TextStyle(
                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,
                                      ),
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
                                backgroundColor: emergency
                                    ? Colors.green
                                    : Colors.red,

                                label: Text(
                                  emergency ? "OPEN" : "CLOSED",

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
                                color: Colors.red,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  data["address"] ?? "Address Not Available",
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
                                        Icons.bed,
                                        color: Colors.green,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Available Beds",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["availableBeds"] ?? 0}",
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
                                        Icons.hotel,
                                        color: Colors.blue,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Total Beds",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["totalBeds"] ?? 0}",
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
                                        Icons.monitor_heart,
                                        color: Colors.red,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "ICU Beds",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["icuBeds"] ?? 0}",
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

                          Container(
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        color: Colors.indigo,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Doctors",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["doctorCount"] ?? 0}",
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
                                        Icons.medical_services,
                                        color: Colors.teal,
                                      ),

                                      const SizedBox(height: 6),

                                      const Text(
                                        "Departments",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${data["departmentCount"] ?? 0}",
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

                          if ((data["specialties"] ?? "")
                              .toString()
                              .isNotEmpty) ...[
                            const Text(
                              "Specialties",

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              width: double.infinity,

                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(.08),

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Text(
                                data["specialties"] is List
                                    ? (data["specialties"] as List).join(", ")
                                    : (data["specialties"] ?? "").toString(),
                              ),
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
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.all(20),

                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                const Text(
                                                  "Hospital Details",

                                                  style: TextStyle(
                                                    fontSize: 24,

                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 24),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.local_hospital,
                                                  ),

                                                  title: const Text("Hospital"),

                                                  subtitle: Text(
                                                    (data["hospitalName"] ??
                                                            "--")
                                                        .toString(),
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.phone,
                                                  ),

                                                  title: const Text("Phone"),

                                                  subtitle: Text(
                                                    (data["phone"] ?? "--")
                                                        .toString(),
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.location_on,
                                                  ),

                                                  title: const Text("Address"),

                                                  subtitle: Text(
                                                    (data["address"] ?? "--")
                                                        .toString(),
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.bed,
                                                  ),

                                                  title: const Text(
                                                    "Available Beds",
                                                  ),

                                                  subtitle: Text(
                                                    "${data["availableBeds"] ?? 0}",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.hotel,
                                                  ),

                                                  title: const Text(
                                                    "Total Beds",
                                                  ),

                                                  subtitle: Text(
                                                    "${data["totalBeds"] ?? 0}",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.monitor_heart,
                                                  ),

                                                  title: const Text("ICU Beds"),

                                                  subtitle: Text(
                                                    "${data["icuBeds"] ?? 0}",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.people,
                                                  ),

                                                  title: const Text("Doctors"),

                                                  subtitle: Text(
                                                    "${data["doctorCount"] ?? 0}",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.star,
                                                  ),

                                                  title: const Text("Rating"),

                                                  subtitle: Text(
                                                    ((data["rating"] as num?)
                                                                ?.toDouble() ??
                                                            0.0)
                                                        .toStringAsFixed(1),
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.info,
                                                  ),

                                                  title: const Text(
                                                    "Emergency Service",
                                                  ),

                                                  subtitle: Text(
                                                    emergency
                                                        ? "Available"
                                                        : "Unavailable",
                                                  ),
                                                ),

                                                const SizedBox(height: 20),
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

                              const SizedBox(width: 12),

                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: emergency
                                        ? Colors.red
                                        : Colors.green,
                                  ),

                                  onPressed: () async {
                                    await firestore
                                        .collection("hospitals")
                                        .doc(document.id)
                                        .update({
                                          "emergencyAvailable": !emergency,
                                        });
                                  },

                                  icon: Icon(
                                    emergency ? Icons.close : Icons.check,
                                  ),

                                  label: Text(emergency ? "Disable" : "Enable"),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(.08),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Row(
                              children: [
                                const Icon(Icons.tag, color: Colors.indigo),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    "Hospital ID : ${document.id}",

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
                      "Hospital Summary",
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
                                  Icons.local_hospital,
                                  color: Colors.blue,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  hospitals.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Hospitals"),
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
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  hospitals
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["emergencyAvailable"] == true;
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Emergency ON"),
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
                                  hospitals
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["emergencyAvailable"] == false;
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Emergency OFF"),
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
                                  Icons.bed,
                                  color: Colors.orange,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  hospitals.fold<int>(0, (sum, e) {
                                    final d = e.data() as Map<String, dynamic>;
                                    return sum +
                                        ((d["availableBeds"] ?? 0) as int);
                                  }).toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Available Beds"),
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
                        color: Colors.purple.withOpacity(.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monitor_heart, color: Colors.purple),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Total ICU Beds : ${hospitals.fold<int>(0, (sum, e) {
                                final d = e.data() as Map<String, dynamic>;
                                return sum + ((d["icuBeds"] ?? 0) as int);
                              })}",
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
