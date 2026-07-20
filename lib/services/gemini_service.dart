import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found. Make sure the .env file is loaded.',
      );
    }

    return key;
  }
  // PASTE YOUR NEW GEMINI API KEY HERE

  static Future<String> askGemini(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are an AI emergency healthcare assistant. Give short and clear emergency guidance.\n\nUser: $prompt",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'AI request failed: ${response.statusCode}\n${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
        throw Exception('No response received from Gemini.');
      }

      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
