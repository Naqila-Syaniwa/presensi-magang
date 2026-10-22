import 'dart:math' as math;
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/attendance_config.dart';
import 'package:presensimagang/widgets/custom_button.dart';
import 'package:presensimagang/features/attendance/location_service.dart';
import 'package:presensimagang/features/attendance/radius_checker.dart';
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

  final double _radiusMeters = AttendanceConfig.defaultRadiusMeters;

  GoogleMapController? _mapController;
  LatLng? _userLatLng;

  StreamSubscription<Position>? _positionSub;
  double? _accuracy;
  bool _isMocked = false;

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
    _mapController?.dispose();
    _stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _positionSub?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _positionSub?.resume();
      if (_status == LocationStatus.ready) _loadUserPosition(fit: false);
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _service.checkStatus();
    if (!mounted) return;

    if (_status == LocationStatus.deniedForever &&
        status == LocationStatus.denied) {
      return;
    }

    _applyStatus(status);
  }

  Future<void> _requestAccess() async {
    final status = await _service.requestAccess();
    if (!mounted) return;
    _hasAsked = true;
    _applyStatus(status);
  }

  void _applyStatus(LocationStatus status) {
    final becameReady =
        _status != LocationStatus.ready && status == LocationStatus.ready;
    setState(() => _status = status);
    if (becameReady) {
      _loadUserPosition();
      _startTracking();
    } else if (status != LocationStatus.ready) {
      _stopTracking();
    }
  }

  Future<void> _loadUserPosition({bool fit = true}) async {
    try {
      final pos = await _service.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
        _accuracy = pos.accuracy;
        _isMocked = pos.isMocked;
      });
      if (fit) _fitCamera();
    } catch (e) {
      debugPrint('Gagal mengambil posisi: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 300), _fitCamera);
  }

  Future<void> _fitCamera() async {
    final controller = _mapController;
    if (controller == null) return;

    const metersPerDegreeLat = 111320.0;
    final dLat = _radiusMeters / metersPerDegreeLat;
    final dLng =
        _radiusMeters /
        (metersPerDegreeLat *
            math.cos(AttendanceConfig.officeLatitude * math.pi / 180));
    var minLat = AttendanceConfig.officeLatitude - dLat;
    var maxLat = AttendanceConfig.officeLatitude + dLat;
    var minLng = AttendanceConfig.officeLongitude - dLng;
    var maxLng = AttendanceConfig.officeLongitude + dLng;

    final user = _userLatLng;
    if (user != null) {
      minLat = math.min(minLat, user.latitude);
      maxLat = math.max(maxLat, user.latitude);
      minLng = math.min(minLng, user.longitude);
      maxLng = math.max(maxLng, user.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    } catch (e) {
      debugPrint('Gagal menyesuaikan kamera: $e');
    }
  }

  Future<void> _centerOnUser() async {
    await _loadUserPosition(fit: false);
    final user = _userLatLng;
    if (user == null) return;
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(user, 17));
  }

  bool? get _isInsideRadius {
    final user = _userLatLng;
    if (user == null) return null;

    final distance = calculateDistanceMeters(
      fromLatitude: user.latitude,
      fromLongitude: user.longitude,
      toLatitude: AttendanceConfig.officeLatitude,
      toLongitude: AttendanceConfig.officeLongitude,
    );
    return distance <= _radiusMeters;
  }

  Set<Circle> _buildCircles() {
    final inside = _isInsideRadius;

    final Color color;
    if (inside == null) {
      color = AppColors.action;
    } else if (inside) {
      color = AppColors.success;
    } else {
      color = AppColors.error;
    }

    return {
      Circle(
        circleId: const CircleId('radius'),
        center: _office,
        radius: _radiusMeters,
        fillColor: color.withValues(alpha: 0.18),
        strokeColor: color,
        strokeWidth: 2,
      ),
    };
  }

  void _startTracking() {
    _positionSub?.cancel();
    _positionSub = _service.positionStream().listen(
      _onPosition,
      onError: (Object _) {
        _stopTracking();
        _service.checkStatus().then((s) {
          if (mounted) _applyStatus(s);
        });
      },
    );
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void _onPosition(Position pos) {
    if (!mounted) return;
    setState(() {
      _userLatLng = LatLng(pos.latitude, pos.longitude);
      _accuracy = pos.accuracy;
      _isMocked = pos.isMocked;
    });
  }

  RadiusCheckResult? get _check {
    if (_status != LocationStatus.ready) return null;
    final user = _userLatLng;
    if (user == null) return null;
    return checkRadius(
      userLatitude: user.latitude,
      userLongitude: user.longitude,
      accuracyMeters: _accuracy ?? 0,
      isMocked: _isMocked,
      officeLatitude: _office.latitude,
      officeLongitude: _office.longitude,
      radiusMeters: _radiusMeters,
      maxAccuracyMeters: AttendanceConfig.maxAccuracyMeters,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.ceil()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  ({String text, Color color}) _statusInfo(RadiusCheckResult? r) {
    if (r == null) {
      return (text: 'Menunggu lokasi', color: AppColors.textSecondary);
    }
    if (r.isMocked) {
      return (text: 'Lokasi palsu', color: AppColors.error);
    }
    if (!r.accuracyOk) {
      return (
        text: 'Akurasi rendah (±${r.accuracyMeters.round()} m)',
        color: AppColors.warning,
      );
    }
    if (r.withinRadius) {
      return (text: 'Di dalam radius', color: AppColors.success);
    }
    return (text: 'Di luar radius', color: AppColors.error);
  }

  ClockInNotice _noticeFor(RadiusCheckResult? r) {
    if (_status != LocationStatus.ready) {
      return const ClockInNotice(
        'Aktifkan izin lokasi dan GPS untuk melakukan Clock In.',
        ClockInNoticeTone.warning,
      );
    }
    if (r == null) {
      return const ClockInNotice(
        'Sedang mencari lokasi Anda...',
        ClockInNoticeTone.info,
      );
    }
    if (!r.accuracyOk) {
      return ClockInNotice(
        'Sinyal GPS lemah (akurasi ±${r.accuracyMeters.round()} m, '
        'maks. ${AttendanceConfig.maxAccuracyMeters.round()} m). '
        'Pindah ke area terbuka lalu tunggu sebentar.',
        ClockInNoticeTone.warning,
      );
    }
    if (!r.withinRadius) {
      return ClockInNotice(
        'Anda berada ${_formatDistance(r.distanceMeters)} dari kantor '
        '(maks. ${_formatDistance(r.radiusMeters)}).',
        ClockInNoticeTone.error,
      );
    }
    return const ClockInNotice(
      'Anda berada di area kantor. Konfirmasi Clock In?',
      ClockInNoticeTone.success,
    );
  }

  Future<void> _confirmClockIn() async {
    final now = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Clock In'),
        content: Text(
          'Anda akan Clock In di ${AttendanceConfig.officeName} '
          'pukul ${DateFormat('HH:mm:ss').format(now)}. Lanjutkan?',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          CustomButton(
            label: 'Batal',
            isOutlined: true,
            fullWidth: false,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          CustomButton(
            label: 'Konfirmasi',
            fullWidth: false,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (_check?.isValid != true) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Lokasi Anda berubah dan tidak lagi memenuhi syarat. '
              'Silahkan coba lagi.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      return;
    }
    Navigator.pop(context, true);
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
              child: Builder(
                builder: (context) {
                  final r = _check;
                  final info = _statusInfo(r);

                  return ClockInInfoCard(
                    officeName: AttendanceConfig.officeName,
                    distanceText: r == null
                        ? '-'
                        : _formatDistance(r.distanceMeters),
                    statusText: info.text,
                    statusColor: info.color,
                    onConfirm: r?.isValid == true ? _confirmClockIn : null,
                    notice: _noticeFor(r),
                  );
                },
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

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _office,
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('office'),
              position: _office,
              infoWindow: InfoWindow(title: AttendanceConfig.officeName),
            ),
          },
          circles: _buildCircles(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: _onMapCreated,
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: null,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.action,
            elevation: 2,
            onPressed: _centerOnUser,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
