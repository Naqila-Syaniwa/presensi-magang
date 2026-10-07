import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}