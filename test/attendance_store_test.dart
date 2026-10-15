import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/features/attendance/data/attendance_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uji logika presensi (tanpa UI): aturan, status, keterangan, penyimpanan.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final store = AttendanceStore.instance;
  final day = DateTime(2026, 10, 14);
  DateTime at(int h, int m) => DateTime(2026, 10, 14, h, m);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
  });

  test('awalnya belum Clock In', () {
    expect(store.statusOn(day), AttendanceStatus.notStarted);
    expect(store.statusLabelOn(day), 'Belum Clock In');
    expect(store.logsOn(day), isEmpty);
  });

  test('alur lengkap: Clock In -> istirahat -> Clock Out', () {
    expect(store.clockIn(at(8, 0)).ok, isTrue);
    expect(store.statusOn(day), AttendanceStatus.working);
    expect(store.statusLabelOn(day), 'Bekerja sejak 08:00');

    expect(store.toggleBreak(at(12, 0)).ok, isTrue);
    expect(store.statusOn(day), AttendanceStatus.onBreak);
    expect(store.statusLabelOn(day), 'Istirahat sejak 12:00');

    expect(store.toggleBreak(at(13, 0)).ok, isTrue);
    expect(store.statusOn(day), AttendanceStatus.working);

    expect(store.clockOut(at(16, 0)).ok, isTrue);
    expect(store.statusOn(day), AttendanceStatus.finished);
    expect(store.statusLabelOn(day), 'Presensi selesai pukul 16:00');

    expect(
      store.logsOn(day).map((l) => l.type).toList(),
      [
        AttendanceType.clockIn,
        AttendanceType.startBreak,
        AttendanceType.endBreak,
        AttendanceType.clockOut,
      ],
    );
  });

  test('aturan: aksi yang tidak valid ditolak dan tidak menambah log', () {
    expect(store.clockOut(at(9, 0)).ok, isFalse); // belum Clock In
    expect(store.toggleBreak(at(9, 0)).ok, isFalse); // belum Clock In

    store.clockIn(at(8, 0));
    expect(store.clockIn(at(8, 5)).message, 'Anda sudah Clock In hari ini');

    store.toggleBreak(at(12, 0));
    expect(store.clockOut(at(12, 5)).ok, isFalse); // masih istirahat

    store.toggleBreak(at(13, 0));
    store.clockOut(at(16, 0));
    expect(store.clockIn(at(16, 5)).message, 'Presensi hari ini sudah selesai');
    expect(store.clockOut(at(16, 6)).message, 'Anda sudah Clock Out hari ini');
    expect(store.toggleBreak(at(16, 7)).ok, isFalse);

    expect(store.logsOn(day).length, 4);
  });

  test('keterangan: tepat waktu, terlambat, pulang lebih awal', () {
    expect(store.clockIn(at(7, 55)).message, contains('Tepat waktu'));
    store.resetForTest();

    expect(store.clockIn(at(8, 12)).message, contains('Terlambat 12 menit'));
    expect(store.clockOut(at(15, 30)).message,
        contains('Pulang lebih awal 30 menit'));
    store.resetForTest();

    store.clockIn(at(8, 0));
    expect(store.clockOut(at(16, 0)).message, isNot(contains('lebih awal')));
  });

  test('log hari sebelumnya tidak memengaruhi status hari ini', () {
    store.clockIn(DateTime(2026, 10, 13, 8, 0)); // kemarin, belum Clock Out
    expect(store.statusOn(day), AttendanceStatus.notStarted);
    expect(store.clockIn(at(8, 0)).ok, isTrue);
    expect(store.logs.length, 2);
  });

  test('riwayat tersimpan dan terbaca kembali', () async {
    store.clockIn(at(8, 0));
    store.clockOut(at(16, 0));
    await Future<void>.delayed(const Duration(milliseconds: 20)); // tunggu simpan

    store.resetForTest(); // simulasi aplikasi dibuka ulang
    expect(store.logs, isEmpty);

    await store.load();
    expect(store.logs.length, 2);
    expect(store.logs.first.type, AttendanceType.clockIn);
    expect(store.statusOn(day), AttendanceStatus.finished);
  });

  test('data tersimpan yang rusak diabaikan', () async {
    SharedPreferences.setMockInitialValues({
      'attendance_logs_v1': '[{"t":"bukan-tanggal","type":"clockIn"},'
          '{"t":"2026-10-14T08:00:00.000","type":"tidak-ada"},'
          '{"t":"2026-10-14T08:00:00.000","type":"clockIn"}]',
    });
    await store.load();
    expect(store.logs.length, 1);
    expect(store.logs.single.type, AttendanceType.clockIn);
  });
}