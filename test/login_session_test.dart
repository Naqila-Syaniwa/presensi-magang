import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/features/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Butuh kontrak Dev A (task 1): AppPrefs.setLoggedIn -> kunci
// 'is_logged_in' (bool) dan 'user_email' (String).

Future<void> _pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    initialRoute: AppRoutes.login,
    routes: {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => const Scaffold(body: Text('HOME PAGE')),
    },
  ));
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('login berhasil: sesi tersimpan lalu pindah ke Home',
      (tester) async {
    await _pumpLogin(tester);
    await _fillAndSubmit(
      tester,
      email: 'budi@mail.com',
      password: 'rahasia123',
    );

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in'), isTrue);
    expect(prefs.getString('user_email'), 'budi@mail.com');
    expect(find.text('HOME PAGE'), findsOneWidget);
  });

  testWidgets('validasi gagal: sesi tidak disimpan dan tetap di Login',
      (tester) async {
    await _pumpLogin(tester);
    await _fillAndSubmit(tester, email: 'bukan-email', password: '123');

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in') ?? false, isFalse);
    expect(prefs.getString('user_email'), isNull);
    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('HOME PAGE'), findsNothing);
  });
}