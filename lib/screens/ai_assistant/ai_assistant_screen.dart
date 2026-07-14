import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController controller = TextEditingController();

  String response = '';

  bool isLoading = false;

  Future<void> askAI() async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final aiResponse = await GeminiService.askGemini(controller.text.trim());

      setState(() {
        response = aiResponse;
      });
    } catch (e) {
      setState(() {
        response = 'Failed to get AI response.\n\n$e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Emergency Assistant')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: controller,

              maxLines: 3,

              decoration: const InputDecoration(
                hintText: 'Describe your emergency or symptoms...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : askAI,

                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,

                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ask AI Assistant'),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white10,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: SingleChildScrollView(
                  child: Text(
                    response.isEmpty
                        ? 'AI response will appear here...'
                        : response,

                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
