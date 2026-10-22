
/// Jenis catatan presensi.
enum AttendanceType {
  clockIn('Clock In'),
  startBreak('Start Break'),
  endBreak('End Break'),
  clockOut('Clock Out');

  const AttendanceType(this.label);

  final String label;
}

/// Status presensi pada satu hari, diturunkan dari log hari itu.
enum AttendanceStatus {
  notStarted,
  working,
  onBreak,
  finished,
}

/// Satu catatan presensi.
class AttendanceLog {
  const AttendanceLog({
    required this.time,
    required this.type,
    this.activityNote,
  });

  final DateTime time;
  final AttendanceType type;

  /// Keterangan kegiatan yang diisi sebelum Clock Out.
  /// Null untuk log lain atau data lama.
  final String? activityNote;

  /// Kunci unik untuk mencegah duplikat saat memuat data tersimpan.
  String get key => '${time.millisecondsSinceEpoch}-${type.name}';

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'type': type.name,
        'activityNote': activityNote,
      };

  /// Mengembalikan null bila data rusak agar data lain tetap terbaca.
  static AttendanceLog? tryParse(Object? json) {
    if (json is! Map) return null;

    final time = DateTime.tryParse('${json['t']}');

    final type = AttendanceType.values
        .where((e) => e.name == json['type'])
        .firstOrNull;

    if (time == null || type == null) return null;

    return AttendanceLog(
      time: time,
      type: type,
      activityNote: json['activityNote'] is String
          ? json['activityNote'] as String
          : null,
    );
  }
}

/// Jadwal kerja satu hari (satu presensi saja).
class AttendanceSchedule {
  const AttendanceSchedule({
    required this.name,
    required this.start,
    required this.end,
  });

  /// Nama shift, misalnya "Kerja Reguler".
  final String name;

  /// Jam mulai dan selesai, format "HH:mm".
  final String start;
  final String end;

  String get rangeLabel => '$start - $end';

  DateTime startOn(DateTime day) => _at(day, start);

  DateTime endOn(DateTime day) => _at(day, end);

  static DateTime _at(DateTime day, String hhmm) {
    final parts = hhmm.split(':');

    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Keterangan untuk log: terlambat, tepat waktu, atau pulang lebih awal.
  /// Null bila tidak ada keterangan.
  String? noteFor(AttendanceLog log) {
    switch (log.type) {
      case AttendanceType.clockIn:
        final lateBy = log.time.difference(startOn(log.time)).inMinutes;

        return lateBy > 0 ? 'Terlambat ${_duration(lateBy)}' : 'Tepat waktu';

      case AttendanceType.clockOut:
        final earlyBy = endOn(log.time).difference(log.time).inMinutes;

        return earlyBy > 0 ? 'Pulang lebih awal ${_duration(earlyBy)}' : null;

      case AttendanceType.startBreak:
      case AttendanceType.endBreak:
        return null;
    }
  }

  static String _duration(int minutes) {
    if (minutes < 60) return '$minutes menit';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return remainingMinutes == 0
        ? '$hours jam'
        : '$hours jam $remainingMinutes menit';
  }
}