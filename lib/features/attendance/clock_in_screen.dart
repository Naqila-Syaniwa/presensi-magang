import 'package:flutter/material.dart';
import 'package:presensimagang/features/attendance/location_service.dart';
import 'package:presensimagang/features/attendance/radius_checker.dart';
import 'package:presensimagang/features/attendance/widgets/location_permission_view.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen>
    with WidgetsBindingObserver {
  final LocationService _service = const LocationService();

  LocationStatus? _status;
  bool _hasAsked = false;

  String _output = 'Tekan "Tes lokasi".';
  bool _loading = false;
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final status = await _service.checkStatus();
    if (!mounted) return;

    if (_status == LocationStatus.deniedForever &&
        status == LocationStatus.denied) {
      return;
    }

    setState(() => _status = status);
  }

  Future<void> _requestAccess() async {
    final status = await _service.requestAccess();
    if (!mounted) return;
    setState(() {
      _status = status;
      _hasAsked = true;
    });
  }

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final status = _status;
    if (status == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (status != LocationStatus.ready) {
      return LocationPermissionView(
        status: status,
        hasAsked: _hasAsked,
        onRequest: _requestAccess,
        onOpenAppSettings: _service.openAppSettings,
        onOpenLocationSettings: _service.openLocationSettings,
      );
    }
    return _buildTestContent();
  }

  Widget _buildTestContent() {
    return Padding(
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
    );
  }
}
