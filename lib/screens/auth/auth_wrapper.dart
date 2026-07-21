import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/main_navigation_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

import '../auth/login_screen.dart';

// import '../patient/patient_navigation.dart';
import '../driver/driver_navigation.dart';
import '../admin/admin_navigation.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (_, _) => const LoginScreen(),

      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.data!.exists) {
              return const LoginScreen();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final role = data["role"];
            switch (role) {
              case AppConstants.driverRole:
                return const DriverNavigation();

              case AppConstants.adminRole:
                return const AdminNavigation();

              case AppConstants.patientRole:
                return const MainNavigationScreen();

              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
