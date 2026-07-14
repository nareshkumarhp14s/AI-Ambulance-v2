import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendEmergency({
    required String type,
    required String description,
  }) async {
    Position position = await Geolocator.getCurrentPosition();

    await firestore.collection('emergency_requests').add({
      'type': type,
      'description': description,

      'latitude': position.latitude,
      'longitude': position.longitude,

      'status': 'pending',

      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
