import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/widgets/clock_card_skeleton.dart';
import 'package:presensimagang/widgets/custom_button.dart';

// Nama class, nama file, dan konstruktor jangan diubah (dipakai HomeScreen).

/// Card Clock In/Out: jam & tanggal realtime, lokasi kantor dummy, dan
/// tombol yang bergantian antara Clock In dan Clock Out.
/// Status hanya disimpan di sisi aplikasi (tanpa backend).
class ClockCard extends StatefulWidget {
  const ClockCard({super.key});

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  static const String _officeName = 'Kantor Pusat Jakarta';
  static const String _officeAddress =
      'Jl. Jend. Sudirman Kav. 52-53, Jakarta Selatan';
  static const String _dateLocale = 'id_ID';

  final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  final DateFormat _shortTimeFormat = DateFormat('HH:mm');
  DateFormat? _dateFormat; // baru tersedia setelah data locale dimuat

  late DateTime _now;
  Timer? _timer;

  bool _isClockedIn = false;
  DateTime? _clockInAt;
  DateTime? _lastClockOutAt;

  // Skeleton shimmer singkat saat card pertama kali tampil.
  bool _isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _loadingTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });

    // Muat data locale Indonesia di sini agar main.dart tidak perlu diubah.
    initializeDateFormatting(_dateLocale).then((_) {
      if (!mounted) return;
      setState(() {
        _dateFormat = DateFormat('EEEE, d MMMM y', _dateLocale);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _toggleClock() {
    final now = DateTime.now();
    String message = '';

    setState(() {
      if (_isClockedIn) {
        _isClockedIn = false;
        _lastClockOutAt = now;
        message = 'Clock Out berhasil pukul ${_shortTimeFormat.format(now)}';
      } else {
        _isClockedIn = true;
        _clockInAt = now;
        message = 'Clock In berhasil pukul ${_shortTimeFormat.format(now)}';
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _statusText {
    if (_isClockedIn && _clockInAt != null) {
      return 'Sudah Clock In pukul ${_shortTimeFormat.format(_clockInAt!)}';
    }
    if (_lastClockOutAt != null) {
      return 'Clock Out terakhir pukul '
          '${_shortTimeFormat.format(_lastClockOutAt!)}';
    }
    return 'Belum Clock In';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ClockCardSkeleton();

    final Color statusColor =
        _isClockedIn ? AppColors.success : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lokasi kantor (dummy)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      _officeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      _officeAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jam & tanggal realtime
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _timeFormat.format(_now),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dateFormat?.format(_now) ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Status
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol bergantian Clock In <-> Clock Out
          CustomButton(
            label: _isClockedIn ? 'Clock Out' : 'Clock In',
            backgroundColor:
                _isClockedIn ? AppColors.textPrimary : AppColors.primary,
            onPressed: _toggleClock,
          ),
        ],
      ),
    );
  }
}