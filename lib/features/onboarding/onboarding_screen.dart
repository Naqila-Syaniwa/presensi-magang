import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/app_prefs.dart';

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
              onPressed: () async {
                await AppPrefs.setSeenOnboarding();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}