import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all available hospitals
  Stream<QuerySnapshot<Map<String, dynamic>>> getHospitals() {
    return _firestore
        .collection('hospitals')
        .where('available', isEqualTo: true)
        .snapshots();
  }

  /// Get a single hospital
  Future<DocumentSnapshot<Map<String, dynamic>>> getHospital(
    String hospitalId,
  ) {
    return _firestore.collection('hospitals').doc(hospitalId).get();
  }

  /// Reserve one bed
  static Future<bool> reserveBed(String hospitalId) async {
    try {
      final hospitalRef = FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalId);

      final snapshot = await hospitalRef.get();

      if (!snapshot.exists) {
        print("Hospital not found");
        return false;
      }

      final data = snapshot.data();

      if (data == null) return false;

      int availableBeds = (data['availableBeds'] ?? 0) as int;

      if (availableBeds <= 0) {
        print("No Beds Available");
        return false;
      }

      await hospitalRef.update({'availableBeds': availableBeds - 1});

      print("Bed Reserved Successfully");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Release one bed
  static Future<void> releaseBed(String hospitalId) async {
    final hospitalRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId);

    final snapshot = await hospitalRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data();

    if (data == null) return;

    int availableBeds = (data['availableBeds'] ?? 0) as int;

    await hospitalRef.update({'availableBeds': availableBeds + 1});
  }
}
