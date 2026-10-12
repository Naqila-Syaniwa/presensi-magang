import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/onboarding/onboarding_screen.dart';
import 'package:presensimagang/features/splash/splash_screen.dart';
import 'package:presensimagang/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first launch: splash goes to onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
