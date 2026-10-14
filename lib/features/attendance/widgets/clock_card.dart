
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
/// status dan meneruskan aksi lewat callback.
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

  /// Meneruskan keterangan kegiatan kepada halaman pemanggil.
  final ValueChanged<String> onClockOut;

  final VoidCallback onToggleBreak;

  Color get _statusColor => switch (status) {
        AttendanceStatus.notStarted => AppColors.textSecondary,
        AttendanceStatus.working => AppColors.success,
        AttendanceStatus.onBreak => _kBreakOrange,
        AttendanceStatus.finished => _kClockBlue,
      };

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  /// Memeriksa status sebelum menampilkan dialog Clock Out.
  Future<void> _showClockOutDialog(BuildContext context) async {
    if (status == AttendanceStatus.onBreak) {
      _showMessage(
        context,
        'Akhiri istirahat terlebih dahulu sebelum Clock Out.',
      );
      return;
    }

    if (status == AttendanceStatus.notStarted) {
      _showMessage(
        context,
        'Clock In terlebih dahulu.',
      );
      return;
    }

    if (status == AttendanceStatus.finished) {
      _showMessage(
        context,
        'Kamu sudah Clock Out hari ini.',
      );
      return;
    }

    final activityNote = await showDialog<String>(
      context: context,
      builder: (_) => const _ClockOutDialog(),
    );

    // Jika batal atau dialog ditutup, Clock Out tidak dijalankan.
    if (!context.mounted ||
        activityNote == null ||
        activityNote.trim().isEmpty) {
      return;
    }

    onClockOut(activityNote.trim());
  }

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
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
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
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
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
                        onPressed: () => _showClockOutDialog(context),
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

/// Dialog keterangan kegiatan yang ditampilkan sebelum Clock Out.
/// Controller dikelola oleh State dialog agar lifecycle-nya terjaga.
class _ClockOutDialog extends StatefulWidget {
  const _ClockOutDialog();

  @override
  State<_ClockOutDialog> createState() => _ClockOutDialogState();
}

class _ClockOutDialogState extends State<_ClockOutDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keterangan Kegiatan'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Tuliskan kegiatan yang dilakukan hari ini...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Keterangan kegiatan wajib diisi';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                _controller.text.trim(),
              );
            }
          },
          child: const Text('Clock Out'),
        ),
      ],
    );
  }
}