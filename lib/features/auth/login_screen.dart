import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/validators.dart';
import 'package:presensimagang/widgets/custom_button.dart';
import 'package:presensimagang/widgets/custom_text_field.dart';
import 'package:presensimagang/widgets/theme_x.dart';

// Warna khusus layar login (mengikuti desain referensi).
const Color _kBlue = Color(0xFF0060C0);
const Color _kLink = Color(0xFF1558D6);

// Varian lebih terang untuk mode gelap (biru gelap kurang kontras).
const Color _kBlueOnDark = Color(0xFF6BA8F0);
const Color _kLinkOnDark = Color(0xFF8AB4F8);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;

  /// Error baru tampil setelah user menekan Sign in; sesudah itu validasi
  /// berjalan live supaya pesan hilang begitu input diperbaiki.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Login dummy (tanpa backend): validasi, loading 1,5 detik, simpan sesi,
  /// lalu ke Home. Sesi hanya disimpan setelah validasi lolos.
  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      // Fokus ke field pertama yang bermasalah; field otomatis di-scroll
      // ke atas keyboard.
      if (Validators.email(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Simpan sesi supaya app berikutnya langsung ke Home (auto-login).
    await AppPrefs.setLoggedIn(_emailController.text.trim());
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
    final scheme = context.colors;
    final blue = context.isDark ? _kBlueOnDark : _kBlue;
    final link = context.isDark ? _kLinkOnDark : _kLink;

    return Scaffold(
      // Latar mengikuti scaffoldBackgroundColor tema (terang/gelap).
      // Body menyusut saat keyboard muncul; isinya di-scroll (tanpa overflow).
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          // Ketuk area kosong untuk menutup keyboard.
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(12, 60, 12, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.lineColor),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: _LoginLogo(),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: 'Email',
                          focusColor: blue,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          enabled: !_isLoading,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          focusColor: blue,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enabled: !_isLoading,
                          onFieldSubmitted: (_) => _submit(),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 40),
                        CustomButton.primary(
                          label: 'Sign in',
                          backgroundColor: _kBlue,
                          fontWeight: FontWeight.w400,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        const _OrDivider(),
                        const SizedBox(height: 16),
                        _AltButton(
                          label: 'Sign in dengan ID Karyawan',
                          onPressed: _isLoading
                              ? null
                              : () => _showUnavailable(
                                  'Sign in dengan ID Karyawan'),
                        ),
                        const SizedBox(height: 16),
                        _AltButton(
                          label: 'Sign in dengan nomor telepon',
                          onPressed: _isLoading
                              ? null
                              : () => _showUnavailable(
                                  'Sign in dengan nomor telepon'),
                        ),
                        const SizedBox(height: 16),
                        _AltButton(
                          label: 'Sign in dengan SAML SSO',
                          onPressed: _isLoading
                              ? null
                              : () =>
                                  _showUnavailable('Sign in dengan SAML SSO'),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: CustomButton.text(
                            label: 'Lupa password',
                            color: link,
                            fontWeight: FontWeight.w400,
                            onPressed: _isLoading
                                ? null
                                : () => _showUnavailable('Fitur Lupa password'),
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
      ),
    );
  }
}

/// Tombol alternatif berbingkai (ID Karyawan, nomor telepon, SAML SSO).
class _AltButton extends StatelessWidget {
  const _AltButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomButton.outline(
      label: label,
      color: context.isDark ? _kLinkOnDark : _kLink,
      fontWeight: FontWeight.w400,
      onPressed: onPressed,
    );
  }
}

/// Pembatas "—— atau ——".
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = context.lineColor;

    return Row(
      children: [
        Expanded(child: Divider(color: line, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'atau',
            style: TextStyle(color: context.mutedText, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: line, thickness: 1)),
      ],
    );
  }
}

/// Logo: gambar `assets/images/mekarisign.jpeg` + wordmark "mekari account".
/// Wordmark menyusut otomatis (FittedBox) bila layar sempit atau font besar.
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
          errorBuilder: (_, _, _) => const SizedBox(
            width: 70,
            height: 70,
            child: Icon(Icons.image_not_supported_outlined,
                color: Color(0xFF9A9A9F)),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
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
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}