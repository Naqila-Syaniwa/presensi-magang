import 'package:presensimagang/features/attendance/data/attendance_models.dart';

/// Jadwal dummy: satu presensi, 08.00 - 16.00.
const AttendanceSchedule mockSchedule = AttendanceSchedule(
  name: 'Kerja Reguler',
  start: '08:00',
  end: '16:00',
);

/// Nama kantor dummy. Akan diganti lokasi sungguhan saat integrasi peta.
const String mockOfficeName = 'Kantor Pusat Jakarta';