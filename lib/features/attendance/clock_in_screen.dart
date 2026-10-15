import 'package:flutter/material.dart';
import 'package:presensimagang/features/attendance/location_service.dart';
import 'package:presensimagang/features/attendance/radius_checker.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final LocationService _service = const LocationService();

  String _output = 'Tekan "Tes lokasi".';
  bool _loading = false;
  bool _valid = false;

    Future<void> _test() async {
    setState(() {
      _loading = true;
      _valid = false;
      _output = 'Memeriksa lokasi...';
    });

    try {
      final status = await _service.requestAccess();
      if (status != LocationStatus.ready) {
        _finish('STATUS: $status');
        return;
      }

      final pos = await _service.getCurrentPosition();
      final r = checkRadius(
        userLatitude: pos.latitude,
        userLongitude: pos.longitude,
        accuracyMeters: pos.accuracy,
      );

      _finish(
        'STATUS: $status\n'
        'Posisi: ${pos.latitude.toStringAsFixed(6)}, '
        '${pos.longitude.toStringAsFixed(6)}\n'
        'Akurasi: ${pos.accuracy.toStringAsFixed(1)} m (ok: ${r.accuracyOk})\n'
        'Jarak ke kantor: ${r.distanceMeters.toStringAsFixed(1)} m '
        '(maks ${r.radiusMeters.toStringAsFixed(0)} m)\n'
        'Mock location: ${pos.isMocked}\n'
        'VALID: ${r.isValid}',
        valid: r.isValid,
      );
    } catch (e) {
      _finish('ERROR: $e');
    }
  }

  void _finish(String text, {bool valid = false}) {
    debugPrint(text);
    if (!mounted) return;
    setState(() {
      _output = text;
      _valid = valid;
      _loading = false;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Lokasi (tes)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _test,
              child: Text(_loading ? 'Memeriksa...' : 'Tes lokasi'),
            ),
            const SizedBox(height: 16),
            Text(_output),
            const Spacer(),
            ElevatedButton(
              onPressed: _valid ? () => Navigator.pop(context, true) : null,
              child: const Text('Konfirmasi (tes)'),
            ),
          ],
        ),
      ),
    );
  }
}