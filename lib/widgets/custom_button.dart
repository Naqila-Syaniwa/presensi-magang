import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';

/// Tombol aplikasi dengan dukungan loading state.
///
/// - Default: tombol solid ([backgroundColor]).
/// - [isOutlined] true: tombol berbingkai dengan teks berwarna [backgroundColor].
///
/// Saat [isLoading] true, label diganti spinner dan tombol tidak bisa
/// ditekan (mencegah submit ganda).
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.fullWidth = true,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.borderRadius = 6,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool fullWidth;

  /// Warna isi tombol solid; pada mode outlined dipakai sebagai warna teks.
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onPressed == null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final minSize = Size(fullWidth ? double.infinity : 0, 48);
    const padding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    final Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: backgroundColor,
          backgroundColor: Colors.white,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: minSize,
          padding: padding,
          shape: shape,
          side: const BorderSide(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: fontWeight),
        ),
      );
    } else {
      button = ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          // Tetap berwarna saat loading supaya tidak tampak "mati".
          disabledBackgroundColor:
              isLoading ? backgroundColor : AppColors.border,
          disabledForegroundColor:
              isLoading ? foregroundColor : AppColors.textSecondary,
          minimumSize: minSize,
          padding: padding,
          elevation: 0,
          shape: shape,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: fontWeight),
              ),
      );
    }

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
