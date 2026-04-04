import 'dart:io';

import 'package:duobloom_mobile/data/database/app_database.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:duobloom_mobile/data/repositories/app_repository.dart';
import 'package:duobloom_mobile/data/services/auth_service.dart';
import 'package:duobloom_mobile/data/services/backup_service.dart';
import 'package:duobloom_mobile/data/services/google_media_sync_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('AppDatabase must be initialized in main().'),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(secureStorageProvider)),
);

final googleMediaSyncServiceProvider = Provider<GoogleMediaSyncService>(
  (ref) => GoogleMediaSyncService(),
);

final appRepositoryProvider = Provider<AppRepository>(
  (ref) => AppRepository(
    database: ref.watch(appDatabaseProvider),
    uuid: ref.watch(uuidProvider),
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(appRepositoryProvider)),
);

final appControllerProvider = AsyncNotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends AsyncNotifier<AppState> {
  AppRepository get _repository => ref.read(appRepositoryProvider);
  AuthService get _authService => ref.read(authServiceProvider);
  BackupService get _backupService => ref.read(backupServiceProvider);
  GoogleMediaSyncService get _googleService =>
      ref.read(googleMediaSyncServiceProvider);

  @override
  Future<AppState> build() => _loadState();

  Future<AppState> _loadState() async {
    final profiles = await _repository.getProfiles();
    if (profiles.isEmpty) {
      return AppState.empty();
    }

    final currentProfileId =
            await _repository.getMeta(AppMetaKey.currentProfileId.key) ??
        profiles.first.id;
    final partnerProfileId =
        await _repository.getMeta(AppMetaKey.partnerProfileId.key);
    final perspectiveValue =
            await _repository.getMeta(AppMetaKey.viewPerspective.key) ??
        ViewPerspective.user.name;

    final currentProfile = profiles.firstWhere(
      (profile) => profile.id == currentProfileId,
      orElse: () => profiles.first,
    );
    final partnerProfile = profiles.where((profile) {
          return profile.id == partnerProfileId && profile.id != currentProfile.id;
        }).firstOrNull ??
        profiles.where((profile) => profile.id != currentProfile.id).firstOrNull;

    return AppState(
      profiles: profiles,
      currentProfile: currentProfile,
      partnerProfile: partnerProfile,
      perspective: ViewPerspective.values.byName(perspectiveValue),
      habits: await _repository.getHabits(),
      habitLogs: await _repository.getHabitLogs(),
      workouts: await _repository.getWorkouts(),
      journalEntries: await _repository.getJournalEntries(),
      notes: await _repository.getNotes(),
      cycleEntries: await _repository.getCycleEntries(),
      mediaAssets: await _repository.getMediaAssets(),
    );
  }

  Future<void> refresh() async {
    state = AsyncData(await _loadState());
  }

  Future<void> completeOnboarding(OnboardingData data) async {
    state = const AsyncLoading();

    String? googleEmail = data.googleEmail;
    if (data.authMethod == AuthMethod.google && googleEmail == null) {
      final account = await _googleService.signIn();
      googleEmail = account?.email;
    }

    final passwordHash = data.password == null || data.password!.isEmpty
        ? null
        : _authService.hashPassword(data.password!);

    await _repository.createCouple(
      data: data,
      passwordHash: passwordHash,
      googleEmail: googleEmail,
    );

    await refresh();
  }

  Future<void> togglePerspective() async {
    final current = state.valueOrNull;
    if (current == null || current.partnerProfile == null) {
      return;
    }

    final next = current.perspective == ViewPerspective.user
        ? ViewPerspective.partner
        : ViewPerspective.user;

    await _repository.setMeta(AppMetaKey.viewPerspective.key, next.name);
    state = AsyncData(current.copyWith(perspective: next));
  }

  Future<void> addHabit({
    required String title,
    required String icon,
    required String colorHex,
  }) async {
    final profileId = state.valueOrNull?.viewedProfile?.id;
    if (profileId == null) {
      return;
    }

    await _repository.addHabit(
      profileId: profileId,
      title: title,
      icon: icon,
      colorHex: colorHex,
    );
    await refresh();
  }

  Future<void> toggleHabit(Habit habit) async {
    await _repository.toggleHabitCompletion(habit, DateTime.now());
    await refresh();
  }

  Future<void> addWorkout({
    required String title,
    required int minutes,
    required int intensity,
    String? note,
  }) async {
    final profileId = state.valueOrNull?.viewedProfile?.id;
    if (profileId == null) {
      return;
    }

    await _repository.addWorkout(
      profileId: profileId,
      title: title,
      minutes: minutes,
      intensity: intensity,
      note: note,
    );
    await refresh();
  }

  Future<void> addJournalEntry({
    required String title,
    required String mood,
    required String body,
    required String highlight,
    String? mediaPath,
  }) async {
    final profileId = state.valueOrNull?.viewedProfile?.id;
    if (profileId == null) {
      return;
    }

    await _repository.addJournalEntry(
      profileId: profileId,
      title: title,
      mood: mood,
      body: body,
      highlight: highlight,
      mediaPath: mediaPath,
    );
    await refresh();
  }

  Future<void> addNote({
    required String body,
    required NoteType type,
  }) async {
    final current = state.valueOrNull;
    final author = current?.currentProfile;
    if (author == null) {
      return;
    }

    final recipientId =
        type == NoteType.partner ? current?.partnerProfile?.id : null;

    await _repository.addNote(
      authorProfileId: author.id,
      type: type,
      body: body,
      recipientProfileId: recipientId,
    );
    await refresh();
  }

  Future<void> saveCycle({
    required DateTime cycleStart,
    required int cycleLength,
    required int periodLength,
    String? symptoms,
  }) async {
    final profileId = state.valueOrNull?.viewedProfile?.id;
    if (profileId == null) {
      return;
    }

    await _repository.addCycleEntry(
      profileId: profileId,
      cycleStart: cycleStart,
      cycleLength: cycleLength,
      periodLength: periodLength,
      symptoms: symptoms,
    );
    await refresh();
  }

  Future<String?> connectGoogleDrive() async {
    final currentProfile = state.valueOrNull?.currentProfile;
    if (currentProfile == null) {
      return null;
    }

    final account = await _googleService.signIn();
    if (account == null) {
      return null;
    }

    await _repository.attachGoogleEmail(currentProfile.id, account.email);
    await refresh();
    return account.email;
  }

  Future<String?> uploadMediaToDrive({String? journalEntryId}) async {
    final profile = state.valueOrNull?.currentProfile;
    if (profile == null) {
      return null;
    }

    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );
    final path = pickedFile?.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    final driveFileId = await _googleService.uploadMedia(File(path));
    if (driveFileId == null) {
      return null;
    }

    await _repository.addMediaAsset(
      profileId: profile.id,
      localPath: path,
      driveFileId: driveFileId,
      journalEntryId: journalEntryId,
    );
    await refresh();
    return driveFileId;
  }

  Future<File?> exportBackup(String password) async {
    return _backupService.exportEncryptedBackup(password);
  }

  Future<void> importBackup(String password) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['duobloom'],
      allowMultiple: false,
    );
    final path = pickedFile?.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }

    await _backupService.importEncryptedBackup(
      file: File(path),
      password: password,
    );
    await refresh();
  }

  Future<void> connectPartnerCode(String code) async {
    final currentProfileId = state.valueOrNull?.currentProfile?.id;
    if (currentProfileId == null) {
      return;
    }

    await _repository.connectPartnerCode(
      currentProfileId: currentProfileId,
      code: code,
    );
    await refresh();
  }

  Future<String> requestMockOtp(String phone) {
    return _authService.requestMockOtp(phone);
  }

  Future<bool> verifyMockOtp({
    required String phone,
    required String otp,
  }) {
    return _authService.verifyMockOtp(phone: phone, otp: otp);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
