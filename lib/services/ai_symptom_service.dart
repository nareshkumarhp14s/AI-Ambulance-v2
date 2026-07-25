class AISymptomService {
  AISymptomService._();

  static final AISymptomService instance = AISymptomService._();

  String predictEmergency(List<String> symptoms) {
    final s = symptoms.map((e) => e.toLowerCase()).toList();

    if (s.contains("chest pain") ||
        s.contains("heart pain") ||
        s.contains("left arm pain")) {
      return "Heart Attack";
    }

    if (s.contains("unconscious") || s.contains("not breathing")) {
      return "Critical";
    }

    if (s.contains("head injury") || s.contains("accident")) {
      return "Road Accident";
    }

    if (s.contains("burn")) {
      return "Burn Injury";
    }

    if (s.contains("pregnant")) {
      return "Pregnancy Emergency";
    }

    if (s.contains("fever") && s.contains("cough")) {
      return "Respiratory Emergency";
    }

    return "General Medical Emergency";
  }

  int priorityScore(List<String> symptoms) {
    int score = 0;

    for (final symptom in symptoms) {
      switch (symptom.toLowerCase()) {
        case "unconscious":
          score += 40;
          break;

        case "not breathing":
          score += 40;
          break;

        case "chest pain":
          score += 35;
          break;

        case "heavy bleeding":
          score += 30;
          break;

        case "stroke":
          score += 30;
          break;

        case "burn":
          score += 20;
          break;

        default:
          score += 5;
      }
    }

    return score;
  }

  String priorityLabel(int score) {
    if (score >= 80) return "Critical";
    if (score >= 60) return "High";
    if (score >= 40) return "Medium";
    return "Low";
  }
}
