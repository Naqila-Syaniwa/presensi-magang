import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/auth/login_screen.dart';
import 'package:presensimagang/features/home/widgets/announcement_section.dart';
import 'package:presensimagang/features/home/widgets/promo_banner.dart';

/// Uji overflow di 2 ukuran layar (kecil & besar), skala font normal & 1.3x,
/// dan saat keyboard muncul. Overflow RenderFlex = exception → tes gagal.
const Map<String, Size> _sizes = {
  'kecil 320x568': Size(320, 568),
  'besar 412x915': Size(412, 915),
};
const List<double> _textScales = [1.0, 1.3];

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required Size size,
  double textScale = 1.0,
  double keyboard = 0,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

/// Lepas widget agar Timer/Animation berhenti sebelum tes selesai.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

/// Tiruan susunan Home: banner + pengumuman dalam ListView berpadding 16.
Widget _homeLike() {
  return Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PromoBanner(),
          const SizedBox(height: 16),
          const AnnouncementSection(),
        ],
      ),
    ),
  );
}

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in _textScales) {
      final label = '${entry.key}, font ${scale}x';

      testWidgets('Login tanpa overflow + error tampil – $label',
          (tester) async {
        await _pump(tester, const LoginScreen(),
            size: entry.value, textScale: scale);
        expect(tester.takeException(), isNull);

        // Submit kosong → pesan error muncul di bawah field.
        final submit = find.widgetWithText(ElevatedButton, 'Sign in');
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pump();
        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await _unmount(tester);
      });

      testWidgets('Login saat keyboard muncul – $label', (tester) async {
        await _pump(tester, const LoginScreen(),
            size: entry.value, textScale: scale, keyboard: 280);
        await tester.tap(find.byType(TextFormField).first);
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextFormField).last, 'abc');
        await tester.pump();
        expect(tester.takeException(), isNull);

        await _unmount(tester);
      });

      testWidgets('PromoBanner + Announcement (skeleton → data) – $label',
          (tester) async {
        await _pump(tester, _homeLike(), size: entry.value, textScale: scale);

        // Fase skeleton
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Fase data
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        expect(find.text('Announcements'), findsOneWidget);

        await _unmount(tester);
      });

      testWidgets('Announcement empty state – $label', (tester) async {
        await _pump(
          tester,
          const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AnnouncementSection(
                announcements: [],
                loadingDuration: Duration.zero,
              ),
            ),
          ),
          size: entry.value,
          textScale: scale,
        );
        await tester.pump();
        expect(find.text('No announcement yet'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await _unmount(tester);
      });
    }
  }
}