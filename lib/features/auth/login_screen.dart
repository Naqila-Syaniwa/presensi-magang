import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/validators.dart';
import 'package:presensimagang/widgets/custom_button.dart';
import 'package:presensimagang/widgets/custom_text_field.dart';

// Warna khusus layar login (mengikuti desain referensi).
const Color _kBlue = Color(0xFF0060C0);
const Color _kLink = Color(0xFF1558D6);
const Color _kPageBg = Color(0xFFF1F3F6);
const Color _kLogoPurple = Color(0xFF5B2EF0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login dummy (tanpa backend): validasi, loading 1,5 detik, lalu ke Home.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature belum tersedia')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        // Scroll agar tidak overflow saat keyboard muncul (LGN-06).
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE6E8EC)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: _LoginLogo(),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        focusColor: _kBlue,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: !_isLoading,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        focusColor: _kBlue,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) => _submit(),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        label: 'Sign in',
                        backgroundColor: _kBlue,
                        fontWeight: FontWeight.w400,
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      const _OrDivider(),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Sign in dengan ID Karyawan',
                        isOutlined: true,
                        backgroundColor: _kLink,
                        fontWeight: FontWeight.w400,
                        onPressed: _isLoading
                            ? null
                            : () => _showUnavailable('Sign in dengan ID Karyawan'),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Sign in dengan nomor telepon',
                        isOutlined: true,
                        backgroundColor: _kLink,
                        fontWeight: FontWeight.w400,
                        onPressed: _isLoading
                            ? null
                            : () =>
                                _showUnavailable('Sign in dengan nomor telepon'),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Sign in dengan SAML SSO',
                        isOutlined: true,
                        backgroundColor: _kLink,
                        fontWeight: FontWeight.w400,
                        onPressed: _isLoading
                            ? null
                            : () => _showUnavailable('Sign in dengan SAML SSO'),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => _showUnavailable('Fitur Lupa password'),
                          style: TextButton.styleFrom(
                            foregroundColor: _kLink,
                            minimumSize: const Size(48, 48),
                          ),
                          child: const Text(
                            'Lupa password',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pembatas "—— atau ——".
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'atau',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

/// Logo sementara: bintang ungu + wordmark "mekari account" (digambar
/// dengan kode). Ganti dengan aset asli bila sudah ada, mis.
/// `Image.asset('assets/images/logo.png', height: 56)`.
class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/mekarisign.jpeg',
          width: 70,
          height: 70,
        ),
        const SizedBox(width: 5),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'mekari',
              style: TextStyle(
                fontSize: 22,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9A9A9F),
              ),
            ),
            Text(
              'account',
              style: TextStyle(
                fontSize: 38,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bintang 6 sudut (3 batang membulat yang diputar 60°).
class _StarPainter extends CustomPainter {
  _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = size.center(Offset.zero);
    final barLength = size.width;
    final barThickness = size.width * 0.3;

    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3 + math.pi / 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: barLength,
            height: barThickness,
          ),
          Radius.circular(barThickness / 2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}
