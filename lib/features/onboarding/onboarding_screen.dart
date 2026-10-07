import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_routes.dart';

// STUB: diganti implementasi sebenarnya
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Onboarding'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}