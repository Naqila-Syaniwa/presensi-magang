import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/attendance_config.dart';
import 'package:presensimagang/features/attendance/location_service.dart';
import 'package:presensimagang/features/attendance/widgets/clock_in_info_card.dart';
import 'package:presensimagang/features/attendance/widgets/location_permission_view.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen>
    with WidgetsBindingObserver {
  static const LatLng _office = LatLng(
    AttendanceConfig.officeLatitude,
    AttendanceConfig.officeLongitude,
  );

  final LocationService _service = const LocationService();

  LocationStatus? _status;
  bool _hasAsked = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Attendance')),
      body: Column(
        children: [
          Expanded(child: _buildMapArea()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ClockInInfoCard(
                officeName: AttendanceConfig.officeName,
                distanceText: '-',
                statusText: 'Menunggu lokasi',
                statusColor: AppColors.textSecondary,
                onConfirm: () => Navigator.pop(context, true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
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

    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: _office, zoom: 16),
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
