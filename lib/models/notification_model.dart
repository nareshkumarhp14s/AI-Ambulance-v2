import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final Timestamp? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      body: json["body"] ?? "",
      type: json["type"] ?? "",
      isRead: json["isRead"] ?? false,
      createdAt: json["createdAt"],
    );
  }
}
