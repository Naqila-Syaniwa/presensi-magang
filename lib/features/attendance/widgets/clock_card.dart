import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/features/attendance/widgets/slide_to_break.dart';
import 'package:presensimagang/widgets/custom_button.dart';

const Color _kClockBlue = Color(0xFF2B5CB8);

/// Kartu presensi untuk satu jadwal: tanggal jadwal, nama shift, jam kerja,
/// tombol Clock In / Clock Out, dan slider mulai istirahat.
/// Semua aksi dikirim lewat callback (fungsi sebenarnya menyusul).
class ClockCard extends StatelessWidget {
  const ClockCard({
    super.key,
    required this.schedule,
    required this.date,
    required this.onClockIn,
    required this.onClockOut,
    required this.onStartBreak,
  });

  final AttendanceSchedule schedule;
  final DateTime date;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onStartBreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              children: [
                Text(
                  'Schedule: ${DateFormat('d MMM y').format(date)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    schedule.rangeLabel,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Clock In',
                        backgroundColor: _kClockBlue,
                        borderRadius: 8,
                        onPressed: onClockIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Clock Out',
                        backgroundColor: _kClockBlue,
                        borderRadius: 8,
                        onPressed: onClockOut,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SlideToBreak(onCompleted: onStartBreak),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
