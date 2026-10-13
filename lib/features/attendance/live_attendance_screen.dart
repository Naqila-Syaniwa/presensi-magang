import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_data.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_section.dart';
import 'package:presensimagang/features/attendance/widgets/clock_card.dart';

/// Halaman Live Attendance: header merah dengan jam realtime, kartu presensi
/// (ClockCard), dan Attendance Log. Aksi tombol masih placeholder (snackbar).
class LiveAttendanceScreen extends StatelessWidget {
  const LiveAttendanceScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature belum tersedia')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.primary,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const _TopBar(),
                      const SizedBox(height: 4),
                      const _LiveClock(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClockCard(
                          schedule: mockSchedule,
                          date: DateTime.now(),
                          onClockIn: () => _comingSoon(context, 'Clock In'),
                          onClockOut: () => _comingSoon(context, 'Clock Out'),
                          onStartBreak: () =>
                              _comingSoon(context, 'Start Break'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              AttendanceLogSection(
                logs: mockAttendanceLogs,
                onViewLog: () => _comingSoon(context, 'Halaman View Log'),
                onTapLog: (log) =>
                    _comingSoon(context, 'Detail ${log.type}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Expanded(
            child: Text(
              'Live Attendance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Penyeimbang lebar tombol kembali agar judul tepat di tengah.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Jam besar (titik dua berkedip) dan tanggal, diperbarui tiap detik.
/// Dipisah menjadi widget sendiri agar hanya bagian ini yang dibangun ulang.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const timeStyle = TextStyle(
      color: Colors.white,
      fontSize: 44,
      height: 1.1,
      fontWeight: FontWeight.w700,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final hh = DateFormat('HH').format(_now);
    final mm = DateFormat('mm').format(_now);

    return Column(
      children: [
        Semantics(
          label: '$hh:$mm',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hh, style: timeStyle),
                Opacity(
                  opacity: _now.second.isEven ? 1 : 0,
                  child: const Text(':', style: timeStyle),
                ),
                Text(mm, style: timeStyle),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEE, d MMM y').format(_now),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}