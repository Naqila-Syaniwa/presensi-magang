import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_routes.dart';

// STUB: diganti implementasi sebenarnya
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Splash'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.onboarding),
              child: const Text('Go to Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}