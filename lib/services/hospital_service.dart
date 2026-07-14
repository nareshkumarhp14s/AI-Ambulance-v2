import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalService {
  static Future<void> reserveBed() async {
    print('reserveBed called');

    final hospitalRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc('hospital_1');

    final snapshot = await hospitalRef.get();

    if (!snapshot.exists) {
      print('Hospital document not found');
      return;
    }

    final data = snapshot.data();

    if (data == null) {
      print('No data found');
      return;
    }

    double availableBeds = (data['availableBeds'] ?? 0).toDouble();

    print('Current beds: $availableBeds');

    if (availableBeds > 0) {
      await hospitalRef.update({'availableBeds': availableBeds - 1});

      print('Bed Reserved Successfully');
    } else {
      print('No Beds Available');
    }
  }
}
