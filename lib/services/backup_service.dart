import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_service.dart';

class BackupService {
  Future<File> exportEncryptedBackup(String password) async {
    final dbPath = await DatabaseService.instance.databasePath();
    final dbBytes = await File(dbPath).readAsBytes();

    final key = _buildKey(password);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(dbBytes, iv: iv);

    final output = jsonEncode({
      'algorithm': 'AES-CBC',
      'payload': base64Encode(encrypted.bytes),
    });

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'routine_together_backup.rtb'));
    return file.writeAsString(output);
  }

  Future<void> importEncryptedBackup(File backupFile, String password) async {
    final content = jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
    final cipherBytes = base64Decode(content['payload'] as String);

    final key = _buildKey(password);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);

    final dbPath = await DatabaseService.instance.databasePath();
    await File(dbPath).writeAsBytes(decrypted, flush: true);
  }

  enc.Key _buildKey(String password) {
    final digest = sha256.convert(utf8.encode(password));
    return enc.Key(Uint8List.fromList(digest.bytes));
  }
}
