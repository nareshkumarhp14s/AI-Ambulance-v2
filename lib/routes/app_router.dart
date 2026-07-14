import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/auth_wrapper.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/",

  routes: [
    GoRoute(path: "/", builder: (context, state) => const AuthWrapper()),

    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
