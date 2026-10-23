import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/attendance_config.dart';
import 'package:presensimagang/features/attendance/radius_checker.dart';

double _latOffset(double meters) =>
    meters / (6378137.0 * 3.141592653589793 / 180.0);

RadiusCheckResult _check(double metersNorth, {double accuracy = 10}) {
  return checkRadius(
    userLatitude: AttendanceConfig.officeLatitude + _latOffset(metersNorth),
    userLongitude: AttendanceConfig.officeLongitude,
    accuracyMeters: accuracy,
  );
}

void main() {
  group('calculateDistanceMeters', () {
    test('titik yang sama menghasilkan jarak 0', () {
      final d = calculateDistanceMeters(
        fromLatitude: AttendanceConfig.officeLatitude,
        fromLongitude: AttendanceConfig.officeLongitude,
        toLatitude: AttendanceConfig.officeLatitude,
        toLongitude: AttendanceConfig.officeLongitude,
      );
      expect(d, 0);
    });

    test('geser 100 m ke utara menghasilkan sekitar 100 m', () {
      final d = calculateDistanceMeters(
        fromLatitude: AttendanceConfig.officeLatitude,
        fromLongitude: AttendanceConfig.officeLongitude,
        toLatitude: AttendanceConfig.officeLatitude + _latOffset(100),
        toLongitude: AttendanceConfig.officeLongitude,
      );
      expect(d, closeTo(100, 0.5));
    });
  });

  group('checkRadius', () {
    test('di dalam radius (30 m) dan akurasi bagus: valid', () {
      final r = _check(30);
      expect(r.withinRadius, isTrue);
      expect(r.accuracyOk, isTrue);
      expect(r.isValid, isTrue);
      expect(r.distanceMeters, closeTo(30, 0.5));
    });

    test('di luar radius (101 m): tidak valid', () {
      final r = _check(101);
      expect(r.withinRadius, isFalse);
      expect(r.isValid, isFalse);
    });

    test('tepat di batas radius dianggap valid (jarak <= radius)', () {
      final d = _check(100).distanceMeters;

      final atLimit = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude + _latOffset(100),
        userLongitude: AttendanceConfig.officeLongitude,
        accuracyMeters: 10,
        radiusMeters: d,
      );
      expect(atLimit.withinRadius, isTrue);
      expect(atLimit.isValid, isTrue);

      final justOver = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude + _latOffset(100),
        userLongitude: AttendanceConfig.officeLatitude,
        accuracyMeters: 10,
        radiusMeters: d - 0.001,
      );
      expect(justOver.withinRadius, isFalse);
      expect(justOver.isValid, isFalse);
    });

    test('akurasi buruk (60 m > 50 m): tidak valid walau di dalam radius', () {
      final r = _check(10, accuracy: 60);
      expect(r.withinRadius, isTrue);
      expect(r.accuracyOk, isFalse);
      expect(r.isValid, isFalse);
    });

    test('akurasi tepat di batas (50 m): masih valid', () {
      final r = _check(10, accuracy: AttendanceConfig.maxAccuracyMeters);
      expect(r.accuracyOk, isTrue);
      expect(r.isValid, isTrue);
    });

    test('radius kustom (slider 200 m) ikut dipakai', () {
      final r = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude + _latOffset(150),
        userLongitude: AttendanceConfig.officeLongitude,
        accuracyMeters: 10,
        radiusMeters: 200,
      );
      expect(r.withinRadius, isTrue);
      expect(r.radiusMeters, 200);
    });
  });
}
