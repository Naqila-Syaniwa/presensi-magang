import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/main.dart';

void main() {
  testWidgets('app starts at splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Splash'), findsOneWidget);
  });
}
