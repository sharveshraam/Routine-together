import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<GoogleSignInAccount?> signInWithGoogle() => _googleSignIn.signIn();

  Future<bool> mockEmailLogin(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return email.contains('@') && password.length >= 6;
  }

  Future<String> sendMockOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final otp = (100000 + Random().nextInt(900000)).toString();
    return otp;
  }
}
