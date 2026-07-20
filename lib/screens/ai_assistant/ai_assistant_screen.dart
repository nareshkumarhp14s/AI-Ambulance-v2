import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/gemini_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController controller = TextEditingController();

  String response = "";
  bool isLoading = false;

  Future<void> askAI() async {
    if (controller.text.trim().isEmpty) return;

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
        response = "Failed to get AI response.\n\n$e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget quickChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text = text;
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Emergency Assistant"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                quickChip("Heart Attack"),
                quickChip("Road Accident"),
                quickChip("Fire Emergency"),
                quickChip("Breathing Problem"),
                quickChip("Chest Pain"),
                quickChip("High Fever"),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your emergency...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.smart_toy),
                label: Text(
                  isLoading ? "Getting AI Response..." : "Ask AI Assistant",
                ),
                onPressed: isLoading ? null : askAI,
              ),
            ),

            const SizedBox(height: 10),

            if (controller.text.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear"),
                  onPressed: () {
                    controller.clear();

                    setState(() {
                      response = "";
                    });
                  },
                ),
              ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : response.isEmpty
                    ? const Center(
                        child: Text(
                          "AI response will appear here.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                response,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy"),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: response),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied to clipboard"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
