import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_text_styles.dart';
import 'package:presensimagang/features/attendance/location_service.dart';

class LocationPermissionView extends StatelessWidget {
  const LocationPermissionView({
    super.key,
    required this.status,
    required this.hasAsked,
    required this.onRequest,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final LocationStatus status;

  final bool hasAsked;

  final VoidCallback onRequest;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    if (status == LocationStatus.ready) return const SizedBox.shrink();

    final content = _contentFor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.lavender,
                shape: BoxShape.circle,
              ),
              child: Icon(content.icon, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              content.title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content.message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: content.onPressed,
                child: Text(content.buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ViewContent _contentFor() {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return _ViewContent(
          icon: Icons.gps_off,
          title: 'GPS belum aktif',
          message: 'Nyalakan layanan lokasi di perangkat Anda agar posisi dapat ditentukan.',
          buttonLabel: 'Aktifkan GPS',
          onPressed: onOpenLocationSettings,
        );

      case LocationStatus.deniedForever:
        return _ViewContent(
          icon: Icons.lock_outline,
          title: 'Izin lokasi diblokir',
          message:
              'Aplikasi tidak bisa meminta izin lagi. Buka pengaturan '
              'aplikasi, pilih Izin, lalu aktifkan Lokasi.',
          buttonLabel: 'Buka pengaturan',
          onPressed: onOpenAppSettings,
        );

      case LocationStatus.ready:
      case LocationStatus.denied:
        if (hasAsked) {
          return _ViewContent(
            icon: Icons.location_off_outlined,
            title: 'Izin lokasi diperlukan',
            message:
                'Tanpa izin lokasi, Clock In tidak dapat diverifikasi. '
                'Izinkan akses lokasi untuk melanjutkan.',
            buttonLabel: 'Coba lagi',
            onPressed: onRequest,
          );
        }
        return _ViewContent(
          icon: Icons.location_on_outlined,
          title: 'Izinkan akses lokasi',
          message: 'Lokasi dipakai hanya saat Clock In, untuk memastikan Anda '
                   'berada di sekitar kantor. Lokasi tidak dilacak di latar '
                   'belakang.',
          buttonLabel: 'Izinkan lokasi',
          onPressed: onRequest,
        );
    }
  }
}

class _ViewContent {
  const _ViewContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
}
