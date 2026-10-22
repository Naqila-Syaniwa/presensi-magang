import 'package:flutter/material.dart';

/// Jenis tombol.
enum CustomButtonVariant {
  /// Tombol solid utama.
  primary,

  /// Tombol berbingkai (aksi sekunder).
  outline,

  /// Tombol solid merah untuk aksi berbahaya (Keluar, Hapus).
  danger,

  /// Tombol teks tanpa latar (Batal, Lupa password).
  text,
}

/// Tombol aplikasi: satu widget untuk semua jenis tombol.
///
/// Pemakaian satu baris:
/// ```dart
/// CustomButton.primary(label: 'Simpan', onPressed: _save)
/// CustomButton.outline(label: 'Ubah', onPressed: _edit)
/// CustomButton.danger(label: 'Keluar', icon: Icons.logout, onPressed: _out)
/// CustomButton.text(label: 'Batal', onPressed: _cancel)
/// ```
///
/// - [isLoading] true: label diganti spinner dan tombol tidak bisa ditekan
///   (mencegah submit ganda). [onPressed] null: tombol nonaktif.
/// - [icon] opsional, tampil di kiri label.
/// - Warna diambil dari `Theme.of(context).colorScheme` sehingga aman di
///   mode gelap. [backgroundColor]/[foregroundColor] hanya untuk warna
///   khusus (mis. biru Clock In); pada `.outline` dan `.text` parameter
///   `color` menjadi warna teks/ikon.
/// - Konstruktor lama `CustomButton(label:, onPressed:, isOutlined:...)`
///   tetap berfungsi.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  });

  const CustomButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  })  : variant = CustomButtonVariant.primary,
        isOutlined = false;

  const CustomButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    Color? color,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  })  : variant = CustomButtonVariant.outline,
        isOutlined = true,
        backgroundColor = color,
        foregroundColor = null;

  const CustomButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  })  : variant = CustomButtonVariant.danger,
        isOutlined = false,
        backgroundColor = null,
        foregroundColor = null;

  const CustomButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    Color? color,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  })  : variant = CustomButtonVariant.text,
        isOutlined = false,
        backgroundColor = color,
        foregroundColor = null;

  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;

  /// Dipertahankan agar kode lama tetap jalan; sama dengan
  /// `variant: CustomButtonVariant.outline`.
  final bool isOutlined;

  final IconData? icon;
  final bool fullWidth;

  /// Warna isi tombol solid; pada outline/text dipakai sebagai warna teks.
  /// Null = warna bawaan tema.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final FontWeight fontWeight;

  CustomButtonVariant get _effectiveVariant =>
      isOutlined ? CustomButtonVariant.outline : variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kind = _effectiveVariant;
    final bool disabled = isLoading || onPressed == null;

    // Warna dasar per jenis. Mode terang: sama seperti tombol sebelumnya
    // (primary = merah merek lewat colorScheme.secondary).
    final Color accent;
    final Color onAccent;
    switch (kind) {
      case CustomButtonVariant.primary:
        accent = backgroundColor ?? scheme.secondary;
        onAccent = foregroundColor ?? _onColor(backgroundColor, scheme.onSecondary);
      case CustomButtonVariant.danger:
        accent = scheme.error;
        onAccent = scheme.onError;
      case CustomButtonVariant.outline:
      case CustomButtonVariant.text:
        accent = backgroundColor ?? scheme.primary;
        onAccent = accent;
    }

    final Color disabledBg = scheme.onSurface.withValues(alpha: 0.12);
    final Color disabledFg = scheme.onSurface.withValues(alpha: 0.38);
    final Color border = theme.dividerTheme.color ?? scheme.outlineVariant;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final minSize = Size(fullWidth ? double.infinity : 0, 48);
    const padding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    final Color contentColor = kind == CustomButtonVariant.primary ||
            kind == CustomButtonVariant.danger
        ? onAccent
        : accent;
    final Widget child = _content(contentColor);

    final Widget button;
    switch (kind) {
      case CustomButtonVariant.outline:
        button = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            backgroundColor: scheme.surface,
            // Saat loading tetap berwarna supaya tidak tampak "mati".
            disabledForegroundColor: isLoading ? accent : disabledFg,
            minimumSize: minSize,
            padding: padding,
            shape: shape,
            side: BorderSide(color: border),
          ),
          child: child,
        );
      case CustomButtonVariant.text:
        button = TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: accent,
            disabledForegroundColor: isLoading ? accent : disabledFg,
            minimumSize: minSize,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            shape: shape,
          ),
          child: child,
        );
      case CustomButtonVariant.primary:
      case CustomButtonVariant.danger:
        button = ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: onAccent,
            disabledBackgroundColor: isLoading ? accent : disabledBg,
            disabledForegroundColor: isLoading ? onAccent : disabledFg,
            minimumSize: minSize,
            padding: padding,
            elevation: 0,
            shape: shape,
          ),
          child: child,
        );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// Warna teks yang terbaca di atas [bg]; bila [bg] null pakai [fallback].
  static Color _onColor(Color? bg, Color fallback) {
    if (bg == null) return fallback;
    return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final text = Text(
      label,
      style: TextStyle(fontSize: 15, fontWeight: fontWeight),
    );
    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: text),
      ],
    );
  }
}