import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/attendance/data/attendance_store.dart';
import 'package:presensimagang/features/attendance/live_attendance_screen.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_section.dart';
import 'package:presensimagang/features/attendance/widgets/slide_to_break.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uji layar Live Attendance di 2 ukuran layar dan skala font 1x / 1,3x:
/// tidak overflow, semua kontrol berfungsi, riwayat dan detail terbuka.
const Map<String, Size> _sizes = {
  'kecil 320x568': Size(320, 568),
  'besar 412x915': Size(412, 915),
};

Future<void> _pump(WidgetTester tester, Size size, double textScale) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const LiveAttendanceScreen(),
    ),
  );
  // Biarkan pemuatan riwayat tersimpan selesai.
  await tester.pump(const Duration(milliseconds: 100));
}

/// Lepas widget agar Timer jam berhenti sebelum tes selesai.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AttendanceStore.instance.resetForTest();
  });

  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      final label = '${entry.key}, font ${scale}x';

      testWidgets('Alur Clock In -> Clock Out tanpa overflow – $label',
          (tester) async {
        await _pump(tester, entry.value, scale);
        expect(tester.takeException(), isNull);
        expect(find.text('Live Attendance'), findsOneWidget);
        expect(find.text('08:00 - 16:00'), findsOneWidget);
        expect(find.text('Belum Clock In'), findsOneWidget);
        expect(find.byType(AttendanceLogTile), findsNothing);

        await _tapButton(tester, 'Clock In');
        expect(find.textContaining('Clock In berhasil'), findsOneWidget);
        expect(find.byType(AttendanceLogTile), findsOneWidget);
        expect(find.textContaining('Bekerja sejak'), findsOneWidget);

        await _tapButton(tester, 'Clock Out');
        expect(find.textContaining('Clock Out berhasil'), findsOneWidget);
        expect(find.byType(AttendanceLogTile), findsNWidgets(2));
        expect(find.textContaining('Presensi selesai'), findsOneWidget);

        await _tapButton(tester, 'Clock In');
        expect(find.text('Presensi hari ini sudah selesai'), findsOneWidget);
        expect(find.byType(AttendanceLogTile), findsNWidgets(2));
        expect(tester.takeException(), isNull);

        await _unmount(tester);
      });
    }
  }

  testWidgets('Clock Out sebelum Clock In ditolak', (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);

    await _tapButton(tester, 'Clock Out');
    expect(find.text('Anda belum Clock In'), findsOneWidget);
    expect(find.byType(AttendanceLogTile), findsNothing);

    await _unmount(tester);
  });

  testWidgets('Slider istirahat: mulai lalu akhiri', (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);

    // Sebelum Clock In: ditolak.
    final slider = find.byType(SlideToBreak);
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(500, 0));
    await tester.pump();
    expect(find.text('Clock In terlebih dahulu'), findsOneWidget);

    await _tapButton(tester, 'Clock In');

    // Mulai istirahat.
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(500, 0));
    await tester.pump();
    expect(find.textContaining('Start Break berhasil'), findsOneWidget);
    expect(find.textContaining('Istirahat sejak'), findsOneWidget);
    expect(find.text('Slide to end break'), findsOneWidget);

    // Clock Out saat istirahat ditolak.
    await _tapButton(tester, 'Clock Out');
    expect(find.textContaining('Akhiri istirahat'), findsOneWidget);

    // Akhiri istirahat.
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(500, 0));
    await tester.pump();
    expect(find.textContaining('End Break berhasil'), findsOneWidget);
    expect(find.text('Slide to start break'), findsOneWidget);
    expect(find.byType(AttendanceLogTile), findsNWidgets(3));

    await _unmount(tester);
  });

  testWidgets('Geser slider setengah jalan tidak memicu aksi', (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);
    await _tapButton(tester, 'Clock In');

    final slider = find.byType(SlideToBreak);
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(40, 0));
    await tester.pump();

    expect(find.textContaining('Start Break'), findsNothing);
    expect(find.byType(AttendanceLogTile), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('View Log membuka riwayat, tap log membuka detail',
      (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);
    await _tapButton(tester, 'Clock In');

    final viewLog = find.text('View Log');
    await tester.ensureVisible(viewLog);
    await tester.tap(viewLog);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Halaman riwayat terbuka (AppBar berjudul Attendance Log).
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Attendance Log'),
      ),
      findsOneWidget,
    );

    // Tap satu log di riwayat -> bottom sheet detail.
    await tester.tap(find.byType(AttendanceLogTile).last);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.textContaining('Kantor Pusat Jakarta'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _unmount(tester);
  });
}