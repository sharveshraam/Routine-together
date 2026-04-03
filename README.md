# Routine Together (Flutter, Android-first)

A couple-style shared routine mobile application built in **Flutter** (not a web app), with local-first architecture, encrypted backup, partner linking by code, and optional Google media sync.

## 1) Project structure

```text
.
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── core/
│   │   └── app_state.dart
│   ├── data/
│   │   └── sample_data.dart
│   ├── models/
│   │   └── entities.dart
│   ├── screens/
│   │   ├── auth_screen.dart
│   │   ├── growth_screen.dart
│   │   ├── habit_screen.dart
│   │   ├── home_screen.dart
│   │   ├── journal_screen.dart
│   │   ├── notes_screen.dart
│   │   ├── period_screen.dart
│   │   ├── settings_screen.dart
│   │   └── workout_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── backup_service.dart
│   │   ├── database_service.dart
│   │   └── media_sync_service.dart
│   └── widgets/
│       ├── animated_toggle.dart
│       ├── avatar_header.dart
│       └── home_feature_card.dart
├── pubspec.yaml
└── analysis_options.yaml
```

## 2) Implemented UX / UI

- Android-first Material 3 dark UI with animated cards and rounded modern surfaces.
- Avatar header (user + partner), interactive view switch toggle (`User View` / `Partner View`).
- Scrollable feature cards with page transitions.
- Feature pages:
  - Habit Tracker (streak UI)
  - Workout Tracker (weekly chart with `fl_chart`)
  - Growth Progress (days together + growth bars + memory flashbacks)
  - Journal (mind-map style preview expand/collapse)
  - Notes + Partner Notes tabs
  - Period Tracker with prediction timeline
  - Authentication page (Google + email local + mock OTP)
  - Security/Sync page (encrypted backup + Google media sync)

## 3) Local database (no backend)

`DatabaseService` uses **SQLite (`sqflite`)** and creates the tables:

- `users`
- `habits`
- `workouts`
- `journals`
- `notes`
- `period_cycles`

This is local-first and does not require a remote server.

## 4) Encryption backup system

`BackupService`:

- Reads local SQLite DB bytes.
- Encrypts payload with AES-CBC (`encrypt` package).
- Derives key from user password with SHA-256.
- Exports `.rtb` encrypted backup file in app documents dir.
- Supports import/decrypt back to the database file.

> For production: use per-backup random IV + authenticated encryption (AES-GCM) and secure key storage.

## 5) Google API usage (media only)

`AuthService` supports Google Sign-In.

`MediaSyncService` contains a Drive-sync integration point for **media-only cloud usage**.

- Keep habits/journal/notes/workout data local.
- Upload only selected media artifacts to Google Drive/Photos.

## 6) Login system implemented

- Google Sign-In (`google_sign_in`)
- Local email/password validation (offline mock/local auth flow)
- Mobile OTP simulation (mock OTP generator)

## 7) Partner connection model

- Each user has local unique partner code.
- Code can be entered by partner to connect accounts on-device.
- Active screen context can switch between user and partner with bottom toggle.

## 8) Setup guide

### Prerequisites

- Flutter SDK 3.22+ (or latest stable)
- Android Studio + Android SDK
- Java 17

### Install

```bash
flutter pub get
```

### Run on Android

```bash
flutter devices
flutter run -d <android_device_id>
```

### Google Sign-In configuration (Android)

1. Create Firebase project (or Google Cloud OAuth Android client).
2. Add Android package ID (for example: `com.example.routine_together`).
3. Register SHA-1/SHA-256 keys.
4. Add `google-services.json` to `android/app/` if using Firebase route.
5. Update OAuth consent and test users.

### Backup / restore testing

- Open **Backup & Media Sync** screen.
- Tap **Export Encrypted Backup**.
- Verify generated file path output.
- For import flow, call `importEncryptedBackup(file, password)` with same password.

## 9) Next production steps

- Add repository layer + DAO per feature.
- Replace mock auth and OTP with full secure local identity model.
- Add proper partner-code handshake UX and conflict-resolution policy.
- Implement Google Drive file picker + resumable uploads for image/video only.
- Add richer animations (Rive/Lottie) and advanced timeline graph interactions.
