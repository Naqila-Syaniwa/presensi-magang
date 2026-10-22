
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/attendance/widgets/clock_in_info_card.dart';

void main() {
  testWidgets('lokasi palsu: pesan tampil dan tombol nonaktif', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClockInInfoCard(
            officeName: 'DPR RI',
            distanceText: '10 m',
            statusText: 'Lokasi palsu',
            statusColor: Colors.red,
            onConfirm: null,
            warningMessage: 'Lokasi palsu terdeteksi.',
          ),
        ),
      ),
    );

    expect(find.text('Lokasi palsu terdeteksi.'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
