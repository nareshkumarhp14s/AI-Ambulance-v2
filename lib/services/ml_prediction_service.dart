import 'dart:math';

class MLPredictionService {
  MLPredictionService._();

  static final MLPredictionService instance = MLPredictionService._();

  /// Predict Emergency Severity (0-100)
  int predictSeverity({
    required int age,
    required bool unconscious,
    required bool breathingProblem,
    required bool bleeding,
    required bool accident,
    required bool chestPain,
    required bool strokeSymptoms,
  }) {
    int score = 0;

    if (age >= 60) score += 10;
    if (unconscious) score += 30;
    if (breathingProblem) score += 25;
    if (bleeding) score += 20;
    if (accident) score += 20;
    if (chestPain) score += 25;
    if (strokeSymptoms) score += 30;

    return min(score, 100);
  }

  /// Priority
  String priority(int score) {
    if (score >= 80) return "Critical";
    if (score >= 60) return "High";
    if (score >= 40) return "Medium";
    return "Low";
  }

  /// Predicted Response Time (minutes)
  int predictResponseTime({
    required double distanceKm,
    required bool trafficHigh,
  }) {
    double speed = trafficHigh ? 25 : 45;

    return ((distanceKm / speed) * 60).round();
  }

  /// Driver Score
  double driverScore({
    required double rating,
    required int trips,
    required double distance,
  }) {
    return rating * 20 + trips * 0.2 - distance * 2;
  }

  /// Hospital Score
  double hospitalScore({
    required int availableBeds,
    required double distance,
    required double rating,
  }) {
    return availableBeds * 5 + rating * 10 - distance * 2;
  }

  /// Best Hospital
  Map<String, dynamic>? bestHospital(List<Map<String, dynamic>> hospitals) {
    if (hospitals.isEmpty) return null;

    hospitals.sort((a, b) {
      final sa = hospitalScore(
        availableBeds: a["beds"],
        distance: a["distance"],
        rating: a["rating"],
      );

      final sb = hospitalScore(
        availableBeds: b["beds"],
        distance: b["distance"],
        rating: b["rating"],
      );

      return sb.compareTo(sa);
    });

    return hospitals.first;
  }

  /// Best Driver
  Map<String, dynamic>? bestDriver(List<Map<String, dynamic>> drivers) {
    if (drivers.isEmpty) return null;

    drivers.sort((a, b) {
      final sa = driverScore(
        rating: a["rating"],
        trips: a["trips"],
        distance: a["distance"],
      );

      final sb = driverScore(
        rating: b["rating"],
        trips: b["trips"],
        distance: b["distance"],
      );

      return sb.compareTo(sa);
    });

    return drivers.first;
  }
}
