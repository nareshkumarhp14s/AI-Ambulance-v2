import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSOSPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("SOS Feature Coming Soon")));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: GestureDetector(
          onTap: _onSOSPressed,
          child: Container(
            width: 220,
            height: 220,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffFF5252), Color(0xffE53935)],
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.45),
                  blurRadius: 35,
                  spreadRadius: 10,
                ),
              ],
            ),

            child: Center(
              child: Container(
                width: 165,
                height: 165,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,

                  border: Border.all(color: Colors.white24, width: 3),
                ),

                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emergency, color: Colors.red, size: 60),

                    SizedBox(height: 12),

                    Text(
                      "SOS",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Tap for Emergency",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
