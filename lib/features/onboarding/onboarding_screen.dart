import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/core/app_text_styles.dart';
import 'package:presensimagang/features/onboarding/onboarding_data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
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
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: onboardingPages[index]),
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Visibility(
                visible: !_isLast,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    textStyle: AppTextStyles.bodyLarge,
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: onboardingPages.length,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                  activeDotColor: AppColors.primaryDark,
                  dotColor: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLast ? _finish : _next,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  textStyle: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: _isLast ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                child: Text(_isLast ? 'Login' : 'Next'),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(data.image, fit: BoxFit.contain),
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
