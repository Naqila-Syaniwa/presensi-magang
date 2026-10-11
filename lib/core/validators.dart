/// Validator untuk TextFormField.
/// Setiap fungsi mengembalikan pesan error (String) bila tidak valid,
/// atau null bila valid — sesuai kontrak `FormFieldValidator<String>`.
///
/// Contoh:
/// ```dart
/// TextFormField(validator: Validators.email)
/// ```
class Validators {
  Validators._();

  static const int minPasswordLength = 6;

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
  );

  /// Email wajib diisi dan berformat valid (LGN-02).
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(text)) return 'Format email tidak valid';
    return null;
  }

  /// Password wajib diisi dan minimal [minPasswordLength] karakter (LGN-02).
  /// Tidak di-trim karena spasi bisa jadi bagian dari password.
  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password wajib diisi';
    if (text.length < minPasswordLength) {
      return 'Password minimal $minPasswordLength karakter';
    }
    return null;
  }
}
