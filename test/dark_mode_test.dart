import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/theme_controller.dart';
import 'package:presensimagang/features/attendance/attendance_history_screen.dart';
import 'package:presensimagang/features/attendance/data/attendance_store.dart';
import 'package:presensimagang/features/attendance/live_attendance_screen.dart';
import 'package:presensimagang/features/auth/login_screen.dart';
import 'package:presensimagang/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layar milik Dev B di mode gelap pada dua ukuran layar: tidak boleh ada
/// overflow atau exception. Memakai ThemeData.dark bawaan Flutter supaya
/// tidak bergantung pada AppTheme.dark milik Dev A.
const _sizes = <Size>[Size(360, 640), Size(411, 891)];

Future<void> _pump(WidgetTester tester, Size size, Widget screen) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: screen,
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Lepas widget agar Timer periodik (jam) berhenti sebelum tes selesai.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'user_email': 'budi@mail.com'});
    AttendanceStore.instance.resetForTest();
    ThemeController.mode.value = ThemeMode.dark;
  });

  for (final size in _sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('Login gelap tanpa overflow ($label)', (tester) async {
      await _pump(tester, size, const LoginScreen());
      expect(tester.takeException(), isNull);
      expect(find.text('Lupa password'), findsOneWidget);
    });

    testWidgets('Setting gelap tanpa overflow ($label)', (tester) async {
      await _pump(tester, size, const SettingsScreen());
      expect(tester.takeException(), isNull);
      expect(find.text('Mode gelap'), findsOneWidget);
    });

    testWidgets('Live Attendance gelap tanpa overflow ($label)',
        (tester) async {
      await _pump(tester, size, const LiveAttendanceScreen());
      expect(tester.takeException(), isNull);
      expect(find.text('Clock In'), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('Riwayat presensi gelap tanpa overflow ($label)',
        (tester) async {
      await _pump(tester, size, const AttendanceHistoryScreen());
      expect(tester.takeException(), isNull);
    });
  }
}