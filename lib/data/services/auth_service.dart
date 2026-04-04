import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService(this._storage);

  final FlutterSecureStorage _storage;

  String hashPassword(String rawPassword) {
    return sha256.convert(utf8.encode('duobloom::$rawPassword')).toString();
  }

  Future<String> requestMockOtp(String phone) async {
    final otp = (Random.secure().nextInt(900000) + 100000).toString();
    final payload = jsonEncode({
      'phone': phone.trim(),
      'otp': otp,
      'expires_at':
          DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    });
    await _storage.write(key: 'mock_otp_session', value: payload);
    return otp;
  }

  Future<bool> verifyMockOtp({
    required String phone,
    required String otp,
  }) async {
    final payload = await _storage.read(key: 'mock_otp_session');
    if (payload == null) {
      return false;
    }

    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final samePhone = decoded['phone'] == phone.trim();
    final sameOtp = decoded['otp'] == otp.trim();
    final notExpired = DateTime.parse(decoded['expires_at'] as String)
        .isAfter(DateTime.now());

    if (samePhone && sameOtp && notExpired) {
      await _storage.delete(key: 'mock_otp_session');
      return true;
    }

    return false;
  }
}
