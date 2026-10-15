import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';

/// Bagian "Attendance Log" di halaman Live Attendance: log hari ini
/// (urut dari paling awal) dan tombol "View Log" ke riwayat lengkap.
class AttendanceLogSection extends StatelessWidget {
  const AttendanceLogSection({
    super.key,
    required this.logs,
    required this.schedule,
    required this.onViewLog,
    required this.onTapLog,
  });

  final List<AttendanceLog> logs;
  final AttendanceSchedule schedule;
  final VoidCallback onViewLog;
  final ValueChanged<AttendanceLog> onTapLog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewLog,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('View Log', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Belum ada presensi hari ini',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            for (final log in logs) ...[
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              AttendanceLogTile(
                log: log,
                note: schedule.noteFor(log),
                onTap: () => onTapLog(log),
              ),
            ],
            const Divider(height: 1, thickness: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

/// Satu baris log: jam + tanggal, jenis (+ keterangan), panah.
class AttendanceLogTile extends StatelessWidget {
  const AttendanceLogTile({
    super.key,
    required this.log,
    required this.onTap,
    this.note,
  });

  final AttendanceLog log;
  final VoidCallback onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('HH:mm').format(log.time),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('d MMM').format(log.time),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.type.label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (note != null)
                    Text(
                      note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}