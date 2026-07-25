import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String statusFilter = "all";

  bool matchSearch(Map<String, dynamic> data) {
    if (searchText.isEmpty) {
      return true;
    }

    final query = searchText.toLowerCase();

    return (data["name"] ?? "").toString().toLowerCase().contains(query) ||
        (data["phone"] ?? "").toString().toLowerCase().contains(query) ||
        (data["email"] ?? "").toString().toLowerCase().contains(query);
  }

  bool matchStatus(Map<String, dynamic> data) {
    if (statusFilter == "all") {
      return true;
    }

    if (statusFilter == "active") {
      return data["active"] == true;
    }

    return data["active"] == false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("users")
          .where("role", isEqualTo: "patient")
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No Patients Found"));
        }

        List<QueryDocumentSnapshot> patients = snapshot.data!.docs;

        patients = patients.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return matchSearch(data) && matchStatus(data);
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
                      "Manage Patients",

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${patients.length} registered patients",

                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: searchController,

                      decoration: InputDecoration(
                        hintText: "Search patient, phone or email",

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
                      "Patient Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: statusFilter == "all",
                          onSelected: (_) {
                            setState(() {
                              statusFilter = "all";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Active"),
                          selected: statusFilter == "active",
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: statusFilter == "active"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              statusFilter = "active";
                            });
                          },
                        ),

                        ChoiceChip(
                          label: const Text("Inactive"),
                          selected: statusFilter == "inactive",
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: statusFilter == "inactive"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              statusFilter = "inactive";
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

            if (patients.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    children: [
                      Icon(Icons.people, size: 70, color: Colors.grey),

                      SizedBox(height: 16),

                      Text(
                        "No Patients Found",
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

                itemCount: patients.length,

                itemBuilder: (context, index) {
                  final document = patients[index];

                  final data = document.data() as Map<String, dynamic>;

                  final active = data["active"] ?? true;

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

                                child: Text(
                                  (data["name"] ?? "P")
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),

                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      data["name"] ?? "Unknown Patient",

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

                                    const SizedBox(height: 2),

                                    Text(
                                      data["email"] ?? "",

                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Chip(
                                backgroundColor: active
                                    ? Colors.green
                                    : Colors.red,

                                label: Text(
                                  active ? "ACTIVE" : "INACTIVE",

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
                                Icons.bloodtype,
                                color: Colors.red,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  "Blood Group : ${data["bloodGroup"] ?? "Not Available"}",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.cake,
                                color: Colors.pink,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text("Age : ${data["age"] ?? "--"}"),
                              ),

                              const SizedBox(width: 20),

                              const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(child: Text(data["gender"] ?? "--")),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.emergency,
                                color: Colors.orange,
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  "Emergency Contact : ${data["emergencyContact"] ?? "Not Available"}",
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

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Medical Information",

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),

                                          const SizedBox(height: 6),

                                          const Text(
                                            "Emergencies",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            "${data["totalEmergencies"] ?? 0}",
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
                                            color: Colors.green,
                                          ),

                                          const SizedBox(height: 6),

                                          const Text(
                                            "Health Status",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            data["healthStatus"] ?? "Normal",
                                            textAlign: TextAlign.center,
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
                                            Icons.history,
                                            color: Colors.indigo,
                                          ),

                                          const SizedBox(height: 6),

                                          const Text(
                                            "Last Request",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            data["lastEmergency"] ?? "--",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if ((data["medicalHistory"] ?? "")
                              .toString()
                              .isNotEmpty) ...[
                            const SizedBox(height: 18),

                            const Text(
                              "Medical History",

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              width: double.infinity,

                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(.06),

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Text(data["medicalHistory"]),
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
                                                  "Patient Profile",

                                                  style: TextStyle(
                                                    fontSize: 24,

                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 24),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.person,
                                                  ),

                                                  title: const Text("Name"),

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
                                                    Icons.email,
                                                  ),

                                                  title: const Text("Email"),

                                                  subtitle: Text(
                                                    data["email"] ?? "--",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.bloodtype,
                                                  ),

                                                  title: const Text(
                                                    "Blood Group",
                                                  ),

                                                  subtitle: Text(
                                                    data["bloodGroup"] ?? "--",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.cake,
                                                  ),

                                                  title: const Text("Age"),

                                                  subtitle: Text(
                                                    "${data["age"] ?? "--"}",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.person_outline,
                                                  ),

                                                  title: const Text("Gender"),

                                                  subtitle: Text(
                                                    data["gender"] ?? "--",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.call,
                                                  ),

                                                  title: const Text(
                                                    "Emergency Contact",
                                                  ),

                                                  subtitle: Text(
                                                    data["emergencyContact"] ??
                                                        "--",
                                                  ),
                                                ),

                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.favorite,
                                                  ),

                                                  title: const Text(
                                                    "Health Status",
                                                  ),

                                                  subtitle: Text(
                                                    data["healthStatus"] ??
                                                        "Normal",
                                                  ),
                                                ),

                                                if (data["createdAt"] != null)
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.calendar_month,
                                                    ),

                                                    title: const Text(
                                                      "Registered On",
                                                    ),

                                                    subtitle: Text(
                                                      (data["createdAt"]
                                                              as Timestamp)
                                                          .toDate()
                                                          .toString(),
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

                                  label: const Text("View Profile"),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: active
                                        ? Colors.red
                                        : Colors.green,
                                  ),

                                  onPressed: () async {
                                    await firestore
                                        .collection("users")
                                        .doc(document.id)
                                        .update({"active": !active});
                                  },

                                  icon: Icon(
                                    active ? Icons.block : Icons.check_circle,
                                  ),

                                  label: Text(active ? "Block" : "Activate"),
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
                                const Icon(Icons.info, color: Colors.indigo),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    "Patient ID : ${document.id}",

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
                      "Patient Summary",
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
                                  patients.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Total Patients"),
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
                                  patients
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["active"] == true;
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Active"),
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
                                  Icons.block,
                                  color: Colors.red,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  patients
                                      .where((e) {
                                        final d =
                                            e.data() as Map<String, dynamic>;
                                        return d["active"] == false;
                                      })
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Inactive"),
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
                                  Icons.emergency,
                                  color: Colors.orange,
                                  size: 34,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  patients.fold<int>(0, (sum, e) {
                                    final d = e.data() as Map<String, dynamic>;
                                    return sum +
                                        ((d["totalEmergencies"] ?? 0) as int);
                                  }).toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text("Total Emergencies"),
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
