import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/splash/splash_screen.dart';
import 'package:presensimagang/main.dart';

void main() {
  testWidgets('app starts at splash', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
