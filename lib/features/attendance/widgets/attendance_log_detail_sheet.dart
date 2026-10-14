import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_data.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';

/// Bottom sheet detail sebuah log presensi.
Future<void> showAttendanceLogDetail(
  BuildContext context, {
  required AttendanceLog log,
  required AttendanceSchedule schedule,
}) {
  final note = schedule.noteFor(log);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.type.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow('Waktu', DateFormat('HH:mm').format(log.time)),
            _DetailRow('Tanggal', DateFormat('EEEE, d MMM y').format(log.time)),
            _DetailRow('Jadwal', '${schedule.name} (${schedule.rangeLabel})'),
            if (note != null) _DetailRow('Keterangan', note),
            const _DetailRow('Lokasi', '$mockOfficeName (dummy)'),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}