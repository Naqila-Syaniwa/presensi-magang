import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/attendance/data/attendance_models.dart';
import 'package:presensimagang/features/attendance/widgets/slide_to_break.dart';
import 'package:presensimagang/widgets/custom_button.dart';

const Color _kClockBlue = Color(0xFF2B5CB8);
const Color _kBreakOrange = Color(0xFFE08A00);

/// Kartu presensi untuk satu jadwal: tanggal jadwal, nama shift, jam kerja,
/// chip status, tombol Clock In / Clock Out, dan slider istirahat.
/// Logika presensi ada di AttendanceStore; kartu ini hanya menampilkan
/// [status] dan meneruskan aksi lewat callback.
class ClockCard extends StatelessWidget {
  const ClockCard({
    super.key,
    required this.schedule,
    required this.date,
    required this.status,
    required this.statusText,
    required this.onClockIn,
    required this.onClockOut,
    required this.onToggleBreak,
  });

  final AttendanceSchedule schedule;
  final DateTime date;
  final AttendanceStatus status;
  final String statusText;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final VoidCallback onToggleBreak;

  Color get _statusColor => switch (status) {
        AttendanceStatus.notStarted => AppColors.textSecondary,
        AttendanceStatus.working => AppColors.success,
        AttendanceStatus.onBreak => _kBreakOrange,
        AttendanceStatus.finished => _kClockBlue,
      };

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
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
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
                SlideToBreak(
                  label: status == AttendanceStatus.onBreak
                      ? 'Slide to end break'
                      : 'Slide to start break',
                  onCompleted: onToggleBreak,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}