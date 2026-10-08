import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/core/app_text_styles.dart';
import 'package:presensimagang/features/onboarding/onboarding_data.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPrefs.setSeenOnboarding();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: onboardingPages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _finish,
                child: const Text('Go to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:32),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                data.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
