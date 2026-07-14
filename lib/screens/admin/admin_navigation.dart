import 'package:flutter/material.dart';

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Admin Dashboard", style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
