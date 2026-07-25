import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_service.dart';

class NotificationSender {
  NotificationSender._();

  static final NotificationSender instance = NotificationSender._();

  Future<void> send({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? bookingId,
    String? driverId,
    Map<String, dynamic>? extra,
  }) async {
    final doc = FirestoreService.instance.notifications.doc();

    await doc.set({
      "id": doc.id,
      "userId": userId,
      "bookingId": bookingId,
      "driverId": driverId,
      "title": title,
      "body": body,
      "type": type,
      "isRead": false,
      "createdAt": FieldValue.serverTimestamp(),
      ...?extra,
    });
  }
}
