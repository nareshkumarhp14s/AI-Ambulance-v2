import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientBookingService {
  PatientBookingService._();

  static final instance = PatientBookingService._();

  Future<String?> getActiveRequestId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('booking_history')
        .where('patientId', isEqualTo: uid)
        .where(
          'status',
          whereIn: [
            'searching',
            'waiting_driver',
            'assigned',
            'accepted',
            'arrived',
            'ongoing',
          ],
        )
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first['requestId'];
  }
}
