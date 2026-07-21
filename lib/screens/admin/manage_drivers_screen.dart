import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageDriversScreen extends StatelessWidget {
  const ManageDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Drivers"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("drivers")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Drivers Found"));
          }

          final drivers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final data = drivers[index].data();

              final online = data["online"] ?? false;
              final status = data["status"] ?? "offline";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: online ? Colors.green : Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(data["name"] ?? "Driver"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["phone"] ?? ""),
                      Text(
                        "Ambulance : ${data["ambulanceNo"] ?? "Not Assigned"}",
                      ),
                      Text("Status : ${status.toUpperCase()}"),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case "view":
                          break;
                        case "edit":
                          break;
                        case "delete":
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "view", child: Text("View")),
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
