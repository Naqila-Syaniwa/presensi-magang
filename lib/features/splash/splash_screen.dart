import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presensimagang/core/app_prefs.dart';

// STUB: diganti implementasi sebenarnya
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.8, end: 1).animate(curved);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward();
      _goNext();  
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    final seenFuture = AppPrefs.hasSeenOnboarding();
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    final seen = await seenFuture;
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      seen ? AppRoutes.login : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: SvgPicture.asset(
              'assets/images/logo-talenta.svg',
              width: 200,
            ),
          ),
        ),
      ),
    );
  }
}
