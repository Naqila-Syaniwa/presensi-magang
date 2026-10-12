# Presensi Magang (Replika Talenta)

A Flutter replica of the Talenta mobile app's first screens, built as an internship project by a two-person team. The UI follows the reference screenshots in the project brief.

**Flow:** Splash → Onboarding → Login → Home

> This is a learning project. It has no backend: login and all data are dummy. It is not affiliated with Mekari or Talenta, and the brand assets used for the replica belong to their owners.

## Features

| Screen | What it does |
| --- | --- |
| **Splash** | Logo with a fade + scale animation. After 2.5 seconds it opens Onboarding on first launch, or Login if Onboarding was already seen. |
| **Onboarding** | Three swipeable pages with a dot indicator and Skip / Next / Login buttons. Skip and Login save a flag, then open Login. |
| **Login** | Email and password form with validation, a loading button, and a dummy sign-in that continues to Home. |
| **Home** | Header with a time-based greeting, an 8-item menu grid, a promo banner carousel, and an announcements list. The bottom navigation has 5 tabs. |

Notes on Home:

- Only the **Home** tab has content. Employees, Request, Inbox, and Account are placeholders.
- Tapping a menu item or the gift icon shows a "coming soon" message.
- The Clock In/Out card is not shown, because it is not in the reference UI. `clock_card.dart` is kept in the repo but is not used.

## Tech stack

- Flutter 3.47.6 (stable), Dart 3.13.5
- Material (via `package:flutter/material.dart`)
- Packages: `shared_preferences`, `intl`, `google_fonts` (Inter), `smooth_page_indicator`, `flutter_svg`
- Main target: Android

## Getting started

### Prerequisites

- Flutter 3.47.6 (run `flutter --version` and `flutter doctor` to check)
- Android Studio with an Android emulator, or a physical Android device
- On Windows: turn on **Developer Mode** (`start ms-settings:developers`). Flutter plugins need symlink support to build.

### Run

```bash
git clone https://github.com/Naqila-Syaniwa/presensi-magang.git
cd presensi-magang
git checkout dev
flutter pub get
flutter run
```

The Inter font is downloaded by `google_fonts` the first time it is used, so the first run needs an internet connection. Without it, the app falls back to the default font.

### Check and build

```bash
flutter analyze
flutter test
flutter build apk --debug
```

The debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

### See Onboarding again

Onboarding only shows on the first launch. To reset it, clear the app data:

```bash
adb shell pm clear com.example.presensimagang
```

You can also clear storage from the emulator's app settings, or uninstall and reinstall the app.

## Login (dummy)

There is no backend. Any input that passes validation signs in:

- Email: required, valid email format
- Password: required, at least 6 characters

After a short loading delay (about 1.5 seconds), the app opens Home.

## Project structure

```
lib/
├── main.dart                  # App entry point and route map
├── core/                      # Shared contracts
│   ├── app_routes.dart        # Route names
│   ├── app_colors.dart        # Color palette
│   ├── app_text_styles.dart   # Text styles (Inter)
│   ├── app_theme.dart         # ThemeData
│   ├── app_prefs.dart         # shared_preferences (seen-onboarding flag)
│   └── validators.dart        # Email and password validators
├── features/
│   ├── splash/                # Splash screen
│   ├── onboarding/            # Onboarding screen and page data
│   ├── auth/                  # Login screen
│   └── home/
│       ├── home_screen.dart   # Home shell with bottom navigation
│       ├── data/              # Dummy data: menu, user, banners, announcements
│       └── widgets/           # Header, menu grid, skeleton, banner, announcements
└── widgets/                   # Shared widgets: buttons, text field, shimmer
assets/images/                 # Logo, onboarding illustrations, banners
```

### Routes

| Route | Screen |
| --- | --- |
| `/` | Splash |
| `/onboarding` | Onboarding |
| `/login` | Login |
| `/home` | Home |

Navigate with the names in `AppRoutes`, for example `Navigator.pushReplacementNamed(context, AppRoutes.home)`.

## Conventions

- Use `AppColors`, `AppTextStyles`, and `AppTheme` for styling instead of hard-coded values.
- Do not rename constants in `core/`, because other files depend on them.
- Add images to `assets/images/`, which is already declared in `pubspec.yaml`.

### Common changes

- **Add a menu item:** add a `HomeMenuItem` to `homeMenuItems` in `features/home/data/menu_data.dart`.
- **Add a promo banner:** save a PNG in `assets/images/`, then add a `PromoBannerItem` to `mockBanners` in `features/home/data/promo_banner_item.dart`.
- **Add an announcement:** add an `Announcement` to `mockAnnouncements` in `features/home/data/announcement_data.dart`.
- **Add an onboarding page:** add an `OnboardingData` entry to `onboardingPages` in `features/onboarding/onboarding_data.dart`.

## Git workflow

```
main  ←  dev  ←  feature/*
```

- `main` holds the stable version.
- Each developer works on a `feature/...` branch created from `dev`.
- Feature branches are merged into `dev` once they build and pass analysis.
- `dev` is merged into `main` only after the full flow has been tested.

## Known limitations

- Employees, Request, Inbox, and Account tabs are placeholders.
- No backend or real authentication.