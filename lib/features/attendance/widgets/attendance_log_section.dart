import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/widgets/custom_button.dart';
import 'package:presensimagang/widgets/theme_x.dart';

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
    final line = context.lineColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              CustomButton.text(
                label: 'View Log',
                color: context.mutedText,
                fontWeight: FontWeight.w400,
                onPressed: onViewLog,
              ),
            ],
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Belum ada presensi hari ini',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedText),
              ),
            )
          else ...[
            for (final log in logs) ...[
              Divider(height: 1, thickness: 1, color: line),
              AttendanceLogTile(
                log: log,
                note: schedule.noteFor(log),
                onTap: () => onTapLog(log),
              ),
            ],
            Divider(height: 1, thickness: 1, color: line),
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
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('d MMM').format(log.time),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.mutedText,
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
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (note != null)
                    Text(
                      note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.mutedText),
          ],
        ),
      ),
    );
  }
}