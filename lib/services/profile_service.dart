import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> getProfile() async {
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String bloodGroup,
    required String emergencyContact,
    String? photoUrl,
  }) async {
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      "name": name,
      "email": _auth.currentUser?.email,
      "phone": phone,
      "bloodGroup": bloodGroup,
      "emergencyContact": emergencyContact,
      "photoUrl": photoUrl,
      "role": "patient",
      "updatedAt": FieldValue.serverTimestamp(),
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
