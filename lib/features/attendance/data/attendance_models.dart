/// Jadwal kerja satu hari (satu presensi saja).
class AttendanceSchedule {
  const AttendanceSchedule({
    required this.name,
    required this.start,
    required this.end,
  });

  /// Nama shift, mis. "Kerja Reguler".
  final String name;

  /// Jam mulai dan selesai, format "HH:mm".
  final String start;
  final String end;

  String get rangeLabel => '$start - $end';
}

/// Satu baris riwayat presensi (Clock In / Clock Out).
class AttendanceLog {
  const AttendanceLog({required this.time, required this.type});

  final DateTime time;

  /// "Clock In" atau "Clock Out".
  final String type;
}
