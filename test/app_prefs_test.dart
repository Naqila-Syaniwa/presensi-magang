import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensimagang/core/app_prefs.dart';
import 'package:presensimagang/core/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeController.mode.value = ThemeMode.light;
  });

  test('isLoggedIn awalnya false', () async {
    expect(await AppPrefs.isLoggedIn(), isFalse);
  });

  test('setLoggedIn menyimpan sesi dan email', () async {
    await AppPrefs.setLoggedIn('user@gmail.com');

    expect(await AppPrefs.isLoggedIn(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_email'), 'user@gmail.com');
  });

  test('clearSession menghapus sesi dan email', () async {
    await AppPrefs.setLoggedIn('user@gmail.com');

    await AppPrefs.clearSession();

    expect(await AppPrefs.isLoggedIn(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_email'), isNull);
  });

  test('clearSession tidak menghapus seen_onboarding', () async {
    await AppPrefs.setSeenOnboarding();
    await AppPrefs.setLoggedIn('user@gmail.com');

    await AppPrefs.clearSession();

    expect(await AppPrefs.hasSeenOnboarding(), isTrue);
  });

  test('clearSession tidak menghapus theme_mode', () async {
    await ThemeController.setMode(ThemeMode.dark);
    await AppPrefs.setLoggedIn('user@gmail.com');

    await AppPrefs.clearSession();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('tema tersimpan dan dimuat ulang', () async {
    await ThemeController.setMode(ThemeMode.dark);
    expect(ThemeController.mode.value, ThemeMode.dark);

    ThemeController.mode.value = ThemeMode.light;
    await ThemeController.load();

    expect(ThemeController.mode.value, ThemeMode.dark);
  });
}
