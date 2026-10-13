import 'package:presensimagang/features/attendance/data/attendance_models.dart';

/// Jadwal dummy: satu presensi, 08.00 - 16.00.
const AttendanceSchedule mockSchedule = AttendanceSchedule(
  name: 'Kerja Reguler',
  start: '08:00',
  end: '16:00',
);

/// Riwayat presensi dummy (urut dari paling awal, seperti referensi).
final List<AttendanceLog> mockAttendanceLogs = [
  AttendanceLog(time: DateTime(2026, 10, 12, 8, 2), type: 'Clock In'),
  AttendanceLog(time: DateTime(2026, 10, 12, 16, 5), type: 'Clock Out'),
];
