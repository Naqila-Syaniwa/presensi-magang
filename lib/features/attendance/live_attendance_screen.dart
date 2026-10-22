import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/features/attendance/attendance_history_screen.dart';
import 'package:presensimagang/features/attendance/data/attendance_store.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_detail_sheet.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_section.dart';
import 'package:presensimagang/features/attendance/widgets/clock_card.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/widgets/theme_x.dart';

/// Halaman Live Attendance: header merah dengan jam realtime, ClockCard
/// (Clock In / Clock Out / istirahat), dan log presensi hari ini.
class LiveAttendanceScreen extends StatefulWidget {
  const LiveAttendanceScreen({super.key});

  @override
  State<LiveAttendanceScreen> createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  final AttendanceStore _store = AttendanceStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load(); // muat riwayat tersimpan
  }

  void _show(AttendanceResult result) {
    // removeCurrentSnackBar: pesan baru langsung menggantikan yang lama,
    // tidak mengantri saat tombol ditekan berulang.
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.ok ? null : AppColors.error,
        ),
      );
  }

  Future<void> _handleClockIn() async {
    if (_store.statusOn(DateTime.now()) != AttendanceStatus.notStarted) {
      _show(_store.clockIn());
      return;
    }

    final result = await Navigator.pushNamed(context, AppRoutes.clockIn);
    if (!mounted || result != true) return;

    _show(_store.clockIn());
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AttendanceHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final now = DateTime.now();

        return Scaffold(
          backgroundColor: context.colors.surface,
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
                              schedule: _store.schedule,
                              date: now,
                              status: _store.statusOn(now),
                              statusText: _store.statusLabelOn(now),
                              onClockIn: () => _handleClockIn(),
                              onClockOut: (activityNote) =>
                                  _show(_store.clockOutWithNote(activityNote)),
                              onToggleBreak: () => _show(_store.toggleBreak()),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  AttendanceLogSection(
                    logs: _store.logsOn(now),
                    schedule: _store.schedule,
                    onViewLog: _openHistory,
                    onTapLog: (log) => showAttendanceLogDetail(
                      context,
                      log: log,
                      schedule: _store.schedule,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
