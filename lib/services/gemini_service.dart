import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
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

      return data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
