import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/attendance_config.dart';
import 'package:presensimagang/features/attendance/radius_checker.dart';

void main() {
  group('lokasi palsu (mock location)', () {
    test('lokasi asli di titik kantor dianggap valid', () {
      final result = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude,
        userLongitude: AttendanceConfig.officeLongitude,
        accuracyMeters: 10,
      );

      expect(result.isMocked, isFalse);
      expect(result.isValid, isTrue);
    });

    test('lokasi palsu di titik kantor tetap ditolak', () {
      final result = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude,
        userLongitude: AttendanceConfig.officeLongitude,
        accuracyMeters: 10,
        isMocked: true,
      );

      expect(result.withinRadius, isTrue);
      expect(result.accuracyOk, isTrue);
      expect(result.isMocked, isTrue);
      expect(result.isValid, isFalse);
    });

    test('lokasi palsu di luar radius juga ditolak', () {
      final result = checkRadius(
        userLatitude: AttendanceConfig.officeLatitude + 0.01,
        userLongitude: AttendanceConfig.officeLongitude,
        accuracyMeters: 10,
        isMocked: true,
      );

      expect(result.withinRadius, isFalse);
      expect(result.isValid, isFalse);
    });
  });
}
