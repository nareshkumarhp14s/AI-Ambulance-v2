import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository instance = NotificationRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("notifications")
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection("notifications").doc(notificationId).update({
      "isRead": true,
    });
  }

  Future<int> unreadCount() async {
    final user = _auth.currentUser;

    if (user == null) return 0;

    final snapshot = await _firestore
        .collection("notifications")
        .where("userId", isEqualTo: user.uid)
        .where("isRead", isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}
