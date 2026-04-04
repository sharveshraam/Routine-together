# DuoBloom Mobile

Android-first Flutter app for two connected users who want to track habits, workouts, journals, memories, cycle data, and shared growth without a traditional backend.

## What is inside

- Offline-first architecture using `sqflite`
- Local onboarding with Google, email, or phone (mock OTP) flows
- Two-profile couple setup with a local partner code switcher
- Encrypted export/import backup flow using PBKDF2 + AES-GCM
- Google Drive media-only sync service for photos and videos
- Animated, card-based mobile UI with user/partner perspective toggle

## Project Structure

```text
duobloom_mobile/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
├── assets/
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   └── providers.dart
│   ├── core/
│   │   ├── navigation/app_page_route.dart
│   │   ├── theme/app_theme.dart
│   │   ├── utils/app_formatters.dart
│   │   └── widgets/common_widgets.dart
│   ├── data/
│   │   ├── database/app_database.dart
│   │   ├── models/app_models.dart
│   │   ├── repositories/app_repository.dart
│   │   └── services/
│   │       ├── auth_service.dart
│   │       ├── backup_service.dart
│   │       └── google_media_sync_service.dart
│   ├── features/
│   │   ├── auth/onboarding_page.dart
│   │   ├── growth/growth_page.dart
│   │   ├── habits/habit_tracker_page.dart
│   │   ├── home/app_shell.dart
│   │   ├── home/home_page.dart
│   │   ├── journal/journal_page.dart
│   │   ├── notes/notes_page.dart
│   │   ├── period/period_tracker_page.dart
│   │   ├── settings/settings_page.dart
│   │   └── workouts/workout_tracker_page.dart
│   └── main.dart
└── test/
    └── smoke_test.dart
```

## Local Storage Design

The SQLite layer stores:

- `profiles`
- `habits`
- `habit_logs`
- `workouts`
- `journal_entries`
- `notes`
- `cycle_entries`
- `media_assets`
- `app_meta`

`app_meta` stores the current profile id, connected partner id, and active user/partner view.

## Encrypted Backup Design

Backup export serializes every table into one JSON bundle, then encrypts it with:

- PBKDF2-HMAC-SHA256 for key derivation
- Random salt and nonce per export
- AES-GCM for authenticated encryption

The export file extension is `.duobloom`.

## Google Media Sync

The app uses Google Sign-In and Google Drive API for media only.

- Core routine data stays local
- Journal media attachments can be uploaded to Drive
- Each upload stores a local DB record with `drive_file_id`

## Setup Guide

### 1. Install Flutter and Android toolchain

- Install Flutter 3.22 or newer
- Install Android Studio with Android SDK
- Run `flutter doctor`

### 2. Generate native Android shell

This environment did not have the Flutter SDK installed, so the Dart app and project files were created manually. From the app folder, generate the Android shell with:

```powershell
cd "C:\Users\sharvesh ram\Desktop\Projects\New app\duobloom_mobile"
flutter create . --platforms=android
```

This keeps the existing `lib/`, `assets/`, and `pubspec.yaml` while generating the missing native runner files.

### 3. Install packages

```powershell
flutter pub get
```

### 4. Configure Google Sign-In and Drive

1. Create a Google Cloud project.
2. Enable Google Drive API.
3. Create Android OAuth client credentials.
4. Add the Android package name you choose in `flutter create`.
5. Download `google-services.json` only if you later add Firebase. This code does not require Firebase.
6. Add the correct SHA-1/SHA-256 fingerprints for Google Sign-In.

### 5. Android permissions

After `flutter create`, verify these in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### 6. Run the app

```powershell
flutter run
```

## Notes

- Phone login uses a mock OTP flow for the offline prototype.
- Google login is intended for identity and media sync only.
- A future production version should replace local-only authentication with a hardened secure identity flow.
