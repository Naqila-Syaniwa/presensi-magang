import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/features/attendance/data/attendance_store.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_detail_sheet.dart';
import 'package:presensimagang/features/attendance/widgets/attendance_log_section.dart';

/// Riwayat presensi lengkap, dikelompokkan per tanggal (terbaru di atas).
/// Dibuka dari tombol "View Log" di Live Attendance.
class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AttendanceStore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance Log'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final byDay = <DateTime, List<AttendanceLog>>{};
          for (final log in store.logs) {
            final day = DateTime(log.time.year, log.time.month, log.time.day);
            (byDay[day] ??= []).add(log);
          }
          final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

          if (days.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada riwayat presensi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              for (final day in days) ...[
                Container(
                  color: AppColors.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    DateFormat('EEEE, d MMM y').format(day),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                for (final log in byDay[day]!) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AttendanceLogTile(
                      log: log,
                      note: store.schedule.noteFor(log),
                      onTap: () => showAttendanceLogDetail(
                        context,
                        log: log,
                        schedule: store.schedule,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}