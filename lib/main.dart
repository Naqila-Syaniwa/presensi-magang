
import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_theme.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/theme_controller.dart';
import 'package:presensimagang/features/auth/login_screen.dart';
import 'package:presensimagang/features/home/home_screen.dart';
import 'package:presensimagang/features/onboarding/onboarding_screen.dart';
import 'package:presensimagang/features/splash/splash_screen.dart';
import 'package:presensimagang/features/attendance/live_attendance_screen.dart';
import 'package:presensimagang/features/attendance/clock_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Presensi Magang',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.onboarding: (_) => const OnboardingScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.liveAttendance: (_) =>
                const LiveAttendanceScreen(),
            AppRoutes.clockIn: (_) => const ClockInScreen(),
          },
        );
      },
    );
  }
}