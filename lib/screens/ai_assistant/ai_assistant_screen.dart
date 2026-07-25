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
        setState(() {
          controller.text = text;
        });
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
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                    : response.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.smart_toy,
                              color: Colors.white38,
                              size: 60,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "AI response will appear here.",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "AI Assistant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Divider(color: Colors.white24, height: 25),

                          Expanded(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                response,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
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
