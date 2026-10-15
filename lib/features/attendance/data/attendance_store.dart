import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensimagang/features/attendance/data/attendance_data.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';

/// Hasil sebuah aksi presensi: berhasil atau ditolak, beserta pesannya.
class AttendanceResult {
  const AttendanceResult(this.ok, this.message, {this.log});

  final bool ok;
  final String message;
  final AttendanceLog? log;
}

/// Penyimpan status dan riwayat presensi (satu instans untuk seluruh aplikasi).
///
/// - Status hari ini diturunkan dari log hari itu, jadi tidak ada status ganda.
/// - Riwayat disimpan lewat shared_preferences, sehingga bertahan saat layar
///   ditutup atau aplikasi dimulai ulang.
/// - Aturan: satu presensi per hari (Clock In -> [Break] -> Clock Out).
class AttendanceStore extends ChangeNotifier {
  AttendanceStore._();

  static final AttendanceStore instance = AttendanceStore._();

  static const String _prefsKey = 'attendance_logs_v1';

  final AttendanceSchedule schedule = mockSchedule;
  final List<AttendanceLog> _logs = [];
  bool _loaded = false;

  /// Seluruh riwayat, urut dari paling awal.
  List<AttendanceLog> get logs => List.unmodifiable(_logs);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Log pada [day], urut dari paling awal.
  List<AttendanceLog> logsOn(DateTime day) =>
      _logs.where((l) => _sameDay(l.time, day)).toList();

  AttendanceStatus statusOn(DateTime day) {
    final today = logsOn(day);
    if (today.isEmpty) return AttendanceStatus.notStarted;
    return switch (today.last.type) {
      AttendanceType.clockIn ||
      AttendanceType.endBreak =>
        AttendanceStatus.working,
      AttendanceType.startBreak => AttendanceStatus.onBreak,
      AttendanceType.clockOut => AttendanceStatus.finished,
    };
  }

  /// Teks status untuk chip di ClockCard.
  String statusLabelOn(DateTime day) {
    final today = logsOn(day);
    String hm(AttendanceLog l) => DateFormat('HH:mm').format(l.time);
    switch (statusOn(day)) {
      case AttendanceStatus.notStarted:
        return 'Belum Clock In';
      case AttendanceStatus.working:
        final first = today.firstWhere(
          (l) => l.type == AttendanceType.clockIn,
          orElse: () => today.first,
        );
        return 'Bekerja sejak ${hm(first)}';
      case AttendanceStatus.onBreak:
        return 'Istirahat sejak ${hm(today.last)}';
      case AttendanceStatus.finished:
        return 'Presensi selesai pukul ${hm(today.last)}';
    }
  }

  // ---- Aksi -------------------------------------------------------------

  AttendanceResult clockIn([DateTime? now]) {
    final t = now ?? DateTime.now();
    switch (statusOn(t)) {
      case AttendanceStatus.notStarted:
        return _add(AttendanceType.clockIn, t);
      case AttendanceStatus.working:
      case AttendanceStatus.onBreak:
        return const AttendanceResult(false, 'Anda sudah Clock In hari ini');
      case AttendanceStatus.finished:
        return const AttendanceResult(false, 'Presensi hari ini sudah selesai');
    }
  }

  AttendanceResult clockOut([DateTime? now]) {
    final t = now ?? DateTime.now();
    switch (statusOn(t)) {
      case AttendanceStatus.working:
        return _add(AttendanceType.clockOut, t);
      case AttendanceStatus.notStarted:
        return const AttendanceResult(false, 'Anda belum Clock In');
      case AttendanceStatus.onBreak:
        return const AttendanceResult(
            false, 'Akhiri istirahat terlebih dahulu sebelum Clock Out');
      case AttendanceStatus.finished:
        return const AttendanceResult(false, 'Anda sudah Clock Out hari ini');
    }
  }

  /// Mulai istirahat bila sedang bekerja, akhiri istirahat bila sedang istirahat.
  AttendanceResult toggleBreak([DateTime? now]) {
    final t = now ?? DateTime.now();
    switch (statusOn(t)) {
      case AttendanceStatus.working:
        return _add(AttendanceType.startBreak, t);
      case AttendanceStatus.onBreak:
        return _add(AttendanceType.endBreak, t);
      case AttendanceStatus.notStarted:
        return const AttendanceResult(false, 'Clock In terlebih dahulu');
      case AttendanceStatus.finished:
        return const AttendanceResult(false, 'Presensi hari ini sudah selesai');
    }
  }

  AttendanceResult _add(AttendanceType type, DateTime time) {
    final log = AttendanceLog(time: time, type: type);
    _logs
      ..add(log)
      ..sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
    _save();

    final note = schedule.noteFor(log);
    final base =
        '${type.label} berhasil pukul ${DateFormat('HH:mm').format(time)}';
    return AttendanceResult(true, note == null ? base : '$base · $note',
        log: log);
  }

  // ---- Penyimpanan ------------------------------------------------------

  /// Memuat riwayat tersimpan (aman dipanggil berulang; hanya jalan sekali).
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;

      final stored = (jsonDecode(raw) as List)
          .map(AttendanceLog.tryParse)
          .whereType<AttendanceLog>();

      // Gabungkan dengan log yang mungkin sudah ditambah sebelum load selesai.
      final byKey = <String, AttendanceLog>{
        for (final l in [...stored, ..._logs]) l.key: l,
      };
      _logs
        ..clear()
        ..addAll(byKey.values)
        ..sort((a, b) => a.time.compareTo(b.time));
      notifyListeners();
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: mulai dari kosong.
    }
  }

  void _save() => unawaited(_persist());

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_logs.map((l) => l.toJson()).toList()),
      );
    } catch (_) {
      // Gagal menyimpan tidak boleh mengganggu aplikasi.
    }
  }

  /// Hanya untuk tes: kosongkan data di memori.
  @visibleForTesting
  void resetForTest() {
    _logs.clear();
    _loaded = false;
  }
}