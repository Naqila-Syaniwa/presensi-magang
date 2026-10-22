import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/widgets/custom_button.dart';

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData(useMaterial3: true),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('primary: memanggil onPressed saat ditekan', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(
      CustomButton.primary(label: 'Simpan', onPressed: () => taps++),
    ));

    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    expect(taps, 1);
  });

  testWidgets('outline, text, danger memakai widget Material yang sesuai',
      (tester) async {
    await tester.pumpWidget(_wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton.outline(label: 'A', onPressed: () {}),
        CustomButton.text(label: 'B', onPressed: () {}),
        CustomButton.danger(label: 'C', onPressed: () {}),
      ],
    )));

    expect(find.widgetWithText(OutlinedButton, 'A'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'B'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'C'), findsOneWidget);
  });

  testWidgets('danger memakai warna error dari colorScheme', (tester) async {
    await tester.pumpWidget(_wrap(
      CustomButton.danger(label: 'Keluar', onPressed: () {}),
    ));

    final context = tester.element(find.byType(ElevatedButton));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(
      button.style!.backgroundColor!.resolve(<WidgetState>{}),
      Theme.of(context).colorScheme.error,
    );
  });

  testWidgets('isLoading: spinner tampil dan tombol tidak bisa ditekan',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(
      CustomButton.primary(
        label: 'Masuk',
        isLoading: true,
        onPressed: () => taps++,
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('onPressed null: tombol nonaktif', (tester) async {
    await tester.pumpWidget(_wrap(
      const CustomButton.primary(label: 'Simpan', onPressed: null),
    ));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('icon opsional tampil di samping label', (tester) async {
    await tester.pumpWidget(_wrap(
      CustomButton.danger(
        label: 'Keluar',
        icon: Icons.logout,
        onPressed: () {},
      ),
    ));

    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('konstruktor lama dengan isOutlined tetap berfungsi',
      (tester) async {
    await tester.pumpWidget(_wrap(
      CustomButton(
        label: 'Lama',
        isOutlined: true,
        backgroundColor: Colors.blue,
        onPressed: () {},
      ),
    ));

    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('fullWidth: default selebar ruang, text hanya selebar isi',
      (tester) async {
    await tester.pumpWidget(_wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton.primary(label: 'Lebar', onPressed: () {}),
        CustomButton.text(label: 'Sempit', onPressed: () {}),
      ],
    )));

    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getSize(find.byType(ElevatedButton)).width, screenWidth);
    expect(tester.getSize(find.byType(TextButton)).width, lessThan(screenWidth));
  });

  testWidgets('semua jenis tampil tanpa error di mode gelap', (tester) async {
    await tester.pumpWidget(_wrap(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton.primary(label: 'P', onPressed: () {}),
          CustomButton.outline(label: 'O', onPressed: () {}),
          CustomButton.danger(label: 'D', onPressed: () {}),
          CustomButton.text(label: 'T', onPressed: () {}),
          const CustomButton.primary(label: 'Off', onPressed: null),
        ],
      ),
      theme: ThemeData.dark(useMaterial3: true),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('P'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });
}