import 'dart:math' as math;

import 'package:presensimagang/core/attendance_config.dart';

class RadiusCheckResult {
  const RadiusCheckResult({
    required this.distanceMeters,
    required this.radiusMeters,
    required this.accuracyMeters,
    required this.withinRadius,
    required this.accuracyOk,
  });

  // Jarak pengguna ke kantor
  final double distanceMeters;

  // Radius yang dipakai saat pengecekan
  final double radiusMeters;

  // Akurasi GPS saat pengecekan
  final double accuracyMeters;

  // true bila jarak berada di dalam radius
  final bool withinRadius;

  // true bila akurasi kurang lebih sama dengan batas akurasi maksimum
  final bool accuracyOk;

  // Clock In diizinkn hanya bila di dalam radius dan akurasi cukup
  bool get isValid => withinRadius && accuracyOk;
}

const double _earthRadiusMeters = 6378137.0;

double _toRadians(double degree) => degree * math.pi / 180.0;

double calculateDistanceMeters({
  required double fromLatitude,
  required double fromLongitude,
  required double toLatitude,
  required double toLongitude,
}) {
  final dLat = _toRadians(toLatitude - fromLatitude);
  final dLng = _toRadians(toLongitude - fromLongitude);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(fromLatitude)) *
          math.cos(_toRadians(toLatitude)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return _earthRadiusMeters * c;
}

RadiusCheckResult checkRadius({
  required double userLatitude,
  required double userLongitude,
  required double accuracyMeters,
  double officeLatitude = AttendanceConfig.officeLatitude,
  double officeLongitude = AttendanceConfig.officeLongitude,
  double radiusMeters = AttendanceConfig.defaultRadiusMeters,
  double maxAccuracyMeters = AttendanceConfig.maxAccuracyMeters,
}) {
  final distance = calculateDistanceMeters(
    fromLatitude: userLatitude,
    fromLongitude: userLongitude,
    toLatitude: officeLatitude,
    toLongitude: officeLongitude,
  );

  return RadiusCheckResult(
    distanceMeters: distance,
    radiusMeters: radiusMeters,
    accuracyMeters: accuracyMeters,
    withinRadius: distance <= radiusMeters,
    accuracyOk: accuracyMeters <= maxAccuracyMeters,
  );            
}
