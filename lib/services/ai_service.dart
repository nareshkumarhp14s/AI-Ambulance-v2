import 'dart:math';

class AIService {
  AIService._();

  static final AIService instance = AIService._();

  /// Emergency Priority
  String predictPriority({
    required String emergencyType,
    required int age,
    required bool unconscious,
    required bool bleeding,
    required bool breathingProblem,
  }) {
    int score = 0;

    if (unconscious) score += 40;

    if (bleeding) score += 25;

    if (breathingProblem) score += 30;

    if (age >= 60) score += 15;

    switch (emergencyType.toLowerCase()) {
      case "heart attack":
        score += 40;
        break;

      case "stroke":
        score += 35;
        break;

      case "accident":
        score += 30;
        break;

      case "burn":
        score += 20;
        break;

      default:
        score += 10;
    }

    if (score >= 80) return "Critical";

    if (score >= 60) return "High";

    if (score >= 35) return "Medium";

    return "Low";
  }

  /// Estimated Arrival Time
  int predictETA({required double distanceKm, double averageSpeed = 40}) {
    if (averageSpeed <= 0) return 0;

    return (distanceKm / averageSpeed * 60).round();
  }

  /// Hospital Recommendation
  Map<String, dynamic>? recommendHospital(
    List<Map<String, dynamic>> hospitals,
    double patientLat,
    double patientLng,
  ) {
    if (hospitals.isEmpty) return null;

    hospitals.sort((a, b) {
      final d1 = _distance(
        patientLat,
        patientLng,
        a["latitude"],
        a["longitude"],
      );

      final d2 = _distance(
        patientLat,
        patientLng,
        b["latitude"],
        b["longitude"],
      );

      return d1.compareTo(d2);
    });

    return hospitals.first;
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371;

    final dLat = _rad(lat2 - lat1);

    final dLon = _rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double d) => d * pi / 180;
}
