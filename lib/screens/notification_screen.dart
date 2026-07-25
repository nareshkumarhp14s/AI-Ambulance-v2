import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/notification_repository.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: NotificationRepository.instance.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data();

              final isRead = data["isRead"] ?? false;

              return Dismissible(
                key: Key(doc.id),
                background: Container(color: Colors.red),
                onDismissed: (_) async {
                  await FirebaseFirestore.instance
                      .collection("notifications")
                      .doc(doc.id)
                      .delete();
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.grey : Colors.red,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(data["title"] ?? ""),
                  subtitle: Text(data["body"] ?? ""),
                  trailing: isRead
                      ? const Icon(Icons.done_all, color: Colors.green)
                      : const Icon(Icons.fiber_new, color: Colors.red),
                  onTap: () async {
                    await NotificationRepository.instance.markAsRead(doc.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
