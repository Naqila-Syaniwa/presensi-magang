import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/attendance/live_attendance_screen.dart';
import 'package:presensimagang/features/attendance/widgets/slide_to_break.dart';

/// Uji Live Attendance di 2 ukuran layar dan skala font 1x / 1,3x:
/// tidak overflow, tombol bisa diklik, dan slider break bisa digeser.
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
}

/// Lepas widget agar Timer jam berhenti sebelum tes selesai.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      final label = '${entry.key}, font ${scale}x';

      testWidgets('Live Attendance tanpa overflow + tombol bisa diklik – $label',
          (tester) async {
        await _pump(tester, entry.value, scale);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);

        expect(find.text('Live Attendance'), findsOneWidget);
        expect(find.text('08:00 - 16:00'), findsOneWidget);
        expect(find.text('Attendance Log'), findsOneWidget);

        final clockIn = find.widgetWithText(ElevatedButton, 'Clock In');
        await tester.ensureVisible(clockIn);
        await tester.tap(clockIn);
        await tester.pump();
        expect(find.text('Clock In belum tersedia'), findsOneWidget);

        final clockOut = find.widgetWithText(ElevatedButton, 'Clock Out');
        await tester.ensureVisible(clockOut);
        await tester.tap(clockOut);
        await tester.pump();
        expect(find.text('Clock Out belum tersedia'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await _unmount(tester);
      });
    }
  }

  testWidgets('Geser slider break sampai ujung memicu aksi', (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);

    final slider = find.byType(SlideToBreak);
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(500, 0));
    await tester.pump();

    expect(find.text('Start Break belum tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _unmount(tester);
  });

  testWidgets('Geser slider setengah jalan tidak memicu aksi', (tester) async {
    await _pump(tester, _sizes['besar 412x915']!, 1.0);

    final slider = find.byType(SlideToBreak);
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(40, 0));
    await tester.pump();

    expect(find.text('Start Break belum tersedia'), findsNothing);

    await _unmount(tester);
  });
}
