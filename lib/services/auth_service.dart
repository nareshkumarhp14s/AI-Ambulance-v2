import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String role = "patient",
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await _firestore.collection("users").doc(credential.user!.uid).set({
      "uid": credential.user!.uid,
      "name": name,
      "phone": phone,
      "email": email.trim(),
      "role": role,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;

    if (uid != null) {
      await _firestore.collection("users").doc(uid).set({
        "fcmToken": FieldValue.delete(),
      }, SetOptions(merge: true));

      final driver = _firestore.collection("drivers").doc(uid);

      if ((await driver.get()).exists) {
        await driver.set({
          "online": false,
          "status": "offline",
          "currentAssignment": null,
          "fcmToken": FieldValue.delete(),
        }, SetOptions(merge: true));
      }
    }

    await _auth.signOut();
  }
}
