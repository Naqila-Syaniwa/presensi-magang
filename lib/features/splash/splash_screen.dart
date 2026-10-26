import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/widgets/theme_x.dart';

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
    final loggedInFuture = AppPrefs.isLoggedIn();
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    final seen = await seenFuture;
    final loggedIn = await loggedInFuture;
    if (!mounted) return;

    final String route;
    if (loggedIn) {
      route = AppRoutes.home;
    } else if (seen) {
      route = AppRoutes.login;
    } else {
      route = AppRoutes.onboarding;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  Widget _buildLogo(BuildContext context) {
    return SvgPicture.asset(
      context.isDark
          ? 'assets/images/logo-talenta-dark.svg'
          : 'assets/images/logo-talenta.svg',
      width: 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(scale: _scale, child: _buildLogo(context)),
        ),
      ),
    );
  }
}
