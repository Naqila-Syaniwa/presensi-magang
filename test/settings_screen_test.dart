import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/theme_controller.dart';
import 'package:presensimagang/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Butuh kontrak Dev A (task 1): AppPrefs (is_logged_in, user_email,
// theme_mode, clearSession) dan ThemeController.mode / setMode.

Future<void> _pumpSettings(WidgetTester tester) async {
  tester.view.physicalSize = const Size(411, 891);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    initialRoute: AppRoutes.home,
    routes: {
      AppRoutes.home: (_) => const SettingsScreen(),
      AppRoutes.login: (_) => const Scaffold(body: Text('LOGIN PAGE')),
    },
  ));
  await tester.pump();
  await tester.pump();
}

Finder get _logoutButton => find.widgetWithText(ElevatedButton, 'Keluar');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'user_email': 'budi@mail.com',
    });
    ThemeController.mode.value = ThemeMode.light;
  });

  testWidgets('menampilkan nama dan email pengguna', (tester) async {
    await _pumpSettings(tester);

    expect(find.text('budi@mail.com'), findsOneWidget);
    expect(find.text('budi'), findsOneWidget);
    expect(find.text('Mode gelap'), findsOneWidget);
  });

  testWidgets('saklar Mode gelap mengubah dan menyimpan tema', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.pump();

    expect(ThemeController.mode.value, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.pump();
    expect(ThemeController.mode.value, ThemeMode.light);
  });

  testWidgets('Keluar -> Batal: sesi tetap ada', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(_logoutButton);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in'), isTrue);
  });

  testWidgets('Keluar -> konfirmasi: sesi dihapus dan kembali ke Login',
      (tester) async {
    await _pumpSettings(tester);

    await tester.tap(_logoutButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(ElevatedButton, 'Keluar'),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in') ?? false, isFalse);
    expect(find.text('LOGIN PAGE'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);

    // Tidak ada halaman di bawah Login: tombol back tidak kembali ke Home.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}