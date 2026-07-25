import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    final batch = _firestore.batch();

    // Users Collection
    batch.set(
      _firestore.collection(AppConstants.usersCollection).doc(user.uid),
      user.toMap(),
    );

    // Driver Collection
    if (user.role == AppConstants.driverRole) {
      batch.set(_firestore.collection("drivers").doc(user.uid), {
        "uid": user.uid,
        "name": user.name,
        "email": user.email,
        "phone": user.phone,

        "online": false,
        "status": "available",
        "currentAssignment": "",

        "ambulanceNo": "",
        "ambulanceType": "",

        "latitude": 0.0,
        "longitude": 0.0,

        "speed": 0.0,
        "accuracy": 0.0,

        "rating": 0.0,
        "totalTrips": 0,

        "createdAt": FieldValue.serverTimestamp(),
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }
}
