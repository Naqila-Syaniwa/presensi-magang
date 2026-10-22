import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_text_styles.dart';
import 'package:presensimagang/widgets/custom_button.dart';

enum ClockInNoticeTone { info, success, warning, error }

class ClockInNotice {
  const ClockInNotice(this.message, this.tone);

  final String message;
  final ClockInNoticeTone tone;
}

class ClockInInfoCard extends StatelessWidget {
  const ClockInInfoCard({
    super.key,
    required this.officeName,
    required this.distanceText,
    required this.statusText,
    required this.statusColor,
    required this.onConfirm,
    this.notice,
  });

  final String officeName;
  final String distanceText;
  final String statusText;
  final Color statusColor;

  final VoidCallback? onConfirm;

  final ClockInNotice? notice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi kantor',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(officeName, style: AppTextStyles.h3),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _RealtimeClock(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(label: 'Jarak', value: distanceText),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Status',
                    value: statusText,
                    valueColor: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (notice != null) ...[
              _NoticeBox(notice: notice!),
              const SizedBox(height: 12),
            ],
            CustomButton(label: 'Konfirmasi Clock In', onPressed: onConfirm),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.label.copyWith(color: valueColor)),
      ],
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.notice});

  final ClockInNotice notice;

  ({Color color, IconData icon}) get _style {
    switch (notice.tone) {
      case ClockInNoticeTone.success:
        return (color: AppColors.success, icon: Icons.check_circle_outline);
      case ClockInNoticeTone.warning:
        return (color: AppColors.warning, icon: Icons.info_outline);
      case ClockInNoticeTone.error:
        return (color: AppColors.error, icon: Icons.warning_amber_rounded);
      case ClockInNoticeTone.info:
        return (color: AppColors.action, icon: Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, size: 18, color: style.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notice.message,
              style: AppTextStyles.caption.copyWith(color: style.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RealtimeClock extends StatefulWidget {
  const _RealtimeClock();

  @override
  State<_RealtimeClock> createState() => _RealtimeClockState();
}

class _RealtimeClockState extends State<_RealtimeClock> {
  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('HH:mm:ss').format(_now),
          style: AppTextStyles.h3.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEE, d MMM y').format(_now),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
