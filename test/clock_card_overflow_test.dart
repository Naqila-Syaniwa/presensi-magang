import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/home/widgets/clock_card.dart';

const Map<String, Size> _sizes = {
  'kecil 320x568': Size(320, 568),
  'besar 412x915': Size(412, 915),
};

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets(
          'ClockCard tanpa overflow, Clock In ↔ Out – ${entry.key}, font ${scale}x',
          (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = entry.value;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: ClockCard(),
              ),
            ),
          ),
        );

        // Fase skeleton lalu fase isi.
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);

        // Clock In → tombol berubah jadi Clock Out → kembali Clock In.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Clock In'));
        await tester.pump();
        expect(find.widgetWithText(ElevatedButton, 'Clock Out'), findsOneWidget);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Clock Out'));
        await tester.pump();
        expect(find.widgetWithText(ElevatedButton, 'Clock In'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}