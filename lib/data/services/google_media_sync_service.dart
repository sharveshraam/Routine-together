import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class GoogleMediaSyncService {
  GoogleMediaSyncService()
      : _signIn = GoogleSignIn(
          scopes: const [drive.DriveApi.driveFileScope],
        );

  final GoogleSignIn _signIn;

  Future<GoogleSignInAccount?> signIn() async {
    return _signIn.signIn();
  }

  Future<void> signOut() => _signIn.signOut();

  Future<String?> uploadMedia(File file) async {
    final account = _signIn.currentUser ?? await signIn();
    final client = await _authenticatedClient(account);
    if (client == null) {
      return null;
    }

    final api = drive.DriveApi(client);
    final folderId = await _ensureFolder(api, 'DuoBloom Media');
    final media = drive.Media(file.openRead(), await file.length());
    final entry = drive.File()
      ..name = p.basename(file.path)
      ..parents = [folderId]
      ..mimeType = _mimeType(file.path);

    final uploaded = await api.files.create(
      entry,
      uploadMedia: media,
    );
    return uploaded.id;
  }

  Future<List<drive.File>> listRecentMedia() async {
    final account = _signIn.currentUser ?? await signIn();
    final client = await _authenticatedClient(account);
    if (client == null) {
      return [];
    }

    final api = drive.DriveApi(client);
    final folderId = await _ensureFolder(api, 'DuoBloom Media');
    final files = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      $fields: 'files(id,name,createdTime,webViewLink)',
      orderBy: 'createdTime desc',
      pageSize: 20,
    );
    return files.files ?? [];
  }

  Future<String> _ensureFolder(drive.DriveApi api, String name) async {
    final query = await api.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = '$name' and trashed = false",
      $fields: 'files(id,name)',
      pageSize: 1,
    );

    final files = query.files;
    final existing = files != null && files.isNotEmpty ? files.first : null;
    if (existing?.id != null) {
      return existing!.id!;
    }

    final folder = await api.files.create(
      drive.File()
        ..name = name
        ..mimeType = 'application/vnd.google-apps.folder',
    );
    return folder.id!;
  }

  String _mimeType(String path) {
    final extension = p.extension(path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(extension)) {
      return 'image/${extension.replaceFirst('.', '')}';
    }
    if (['.mp4', '.mov', '.m4v'].contains(extension)) {
      return 'video/${extension.replaceFirst('.', '')}';
    }
    return 'application/octet-stream';
  }

  Future<http.Client?> _authenticatedClient(
    GoogleSignInAccount? account,
  ) async {
    if (account == null) {
      return null;
    }

    final headers = await account.authHeaders;
    if (headers.isEmpty) {
      return null;
    }

    return _GoogleAuthClient(headers);
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
