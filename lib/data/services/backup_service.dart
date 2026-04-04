import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:duobloom_mobile/data/repositories/app_repository.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  BackupService(this._repository);

  final AppRepository _repository;

  final _aesGcm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Future<File> exportEncryptedBackup(String password) async {
    final bundle = await _repository.exportBundle();
    final clearBytes = utf8.encode(jsonEncode(bundle));
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final secretBox = await _aesGcm.encrypt(
      clearBytes,
      secretKey: key,
      nonce: nonce,
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/duobloom_backup_$timestamp.duobloom');

    final envelope = jsonEncode({
      'version': 1,
      'algorithm': 'aes-gcm-256',
      'kdf': 'pbkdf2-hmac-sha256',
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'cipher_text': base64Encode(secretBox.cipherText),
    });

    await file.writeAsString(envelope, flush: true);
    return file;
  }

  Future<void> importEncryptedBackup({
    required File file,
    required String password,
  }) async {
    final raw = await file.readAsString();
    final envelope = jsonDecode(raw) as Map<String, dynamic>;

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final mac = base64Decode(envelope['mac'] as String);
    final cipherText = base64Decode(envelope['cipher_text'] as String);

    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final clearBytes = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: key,
    );

    final payload = jsonDecode(utf8.decode(clearBytes)) as Map<String, dynamic>;
    await _repository.importBundle(payload);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
