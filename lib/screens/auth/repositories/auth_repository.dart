import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String bloodGroup,
    required String emergencyContact,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      bloodGroup: bloodGroup,
      emergencyContact: emergencyContact,
      photoUrl: null,
    );

    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
      ...user.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<User> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
