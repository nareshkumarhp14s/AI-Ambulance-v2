import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _saveToken();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
      await _saveToken();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification");
      print(message.notification?.title);
      print(message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked");
      print(message.data);
    });
  }

  Future<void> _saveToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore.collection("users").doc(user.uid).set({
      "fcmToken": token,
    }, SetOptions(merge: true));

    final driverDoc = _firestore.collection("drivers").doc(user.uid);
    if ((await driverDoc.get()).exists) {
      await driverDoc.set({"fcmToken": token}, SetOptions(merge: true));
    }
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {}
}
