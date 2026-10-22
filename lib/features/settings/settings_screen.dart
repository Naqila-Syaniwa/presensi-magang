import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/core/app_routes.dart';
import 'package:presensimagang/core/theme_controller.dart';
import 'package:presensimagang/widgets/custom_button.dart';
import 'package:presensimagang/widgets/theme_x.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layar Setting (tab Account): mode gelap dan Keluar.
///
/// Nama class jangan diubah (dipakai HomeScreen milik Dev A).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Kunci sesuai kontrak AppPrefs (task 1).
  static const String _userEmailKey = 'user_email';

  late final Future<String?> _email = _loadEmail();
  bool _loggingOut = false;

  Future<String?> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Dialog konfirmasi; true bila user memilih Keluar.
  Future<bool> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda perlu masuk lagi untuk menggunakan aplikasi.',
        ),
        actions: [
          CustomButton.text(
            label: 'Batal',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          CustomButton.danger(
            label: 'Keluar',
            fullWidth: false,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirmed = await _confirmLogout();
    if (!confirmed || !mounted) return;

    setState(() => _loggingOut = true);
    await AppPrefs.clearSession();
    if (!mounted) return;

    // Hapus seluruh tumpukan halaman supaya tombol back tidak kembali ke Home.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FutureBuilder<String?>(
            future: _email,
            builder: (context, snapshot) =>
                _ProfileCard(email: snapshot.data),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Tampilan'),
          const _DarkModeTile(),
          const SizedBox(height: 32),
          CustomButton.danger(
            label: 'Keluar',
            icon: Icons.logout,
            isLoading: _loggingOut,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}

/// Kartu nama + email pengguna (bila ada di AppPrefs).
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final hasEmail = email != null && email!.isNotEmpty;
    final name = hasEmail ? email!.split('@').first : 'Pengguna';
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.lineColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: scheme.secondary,
            foregroundColor: scheme.onSecondary,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (hasEmail)
                  Text(
                    email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: context.mutedText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.mutedText,
        ),
      ),
    );
  }
}

/// Saklar "Mode gelap" yang membaca/menulis ThemeController.
class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.lineColor),
      ),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, mode, _) {
          // Mode "system" dianggap gelap bila perangkat sedang gelap.
          final isDark = mode == ThemeMode.dark ||
              (mode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          return SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode gelap'),
            subtitle: const Text('Tampilan gelap untuk seluruh aplikasi'),
            value: isDark,
            onChanged: (value) => ThemeController.setMode(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          );
        },
      ),
    );
  }
}