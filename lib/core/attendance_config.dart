class AttendanceConfig {
  const AttendanceConfig._();

  // Nama kantor
  static const String officeName = 'DPR RI';

  // Koordinat kantor
  static const double officeLatitude = -6.20887304652298;
  static const double officeLongitude = 106.799595943019;

  // Jarak maksimum dari titik kantor agar clock in diizinkan
  static const double defaultRadiusMeters = 100;

  // Akurasi GPS terburuk yang masih dipercaya
  // LEbih buruk dari ini, Clock In ditolak
  static const double maxAccuracyMeters = 50;

  // Batas slider radius
  static const double minRadiusMeters = 50;
  static const double maxRadiusMeters = 500;
}
