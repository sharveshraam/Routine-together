import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final auth = AuthService();
  String status = 'Not authenticated';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Options')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final account = await auth.signInWithGoogle();
                setState(() => status = account == null ? 'Google canceled' : 'Google: ${account.email}');
              },
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final ok = await auth.mockEmailLogin('demo@example.com', 'password123');
                setState(() => status = ok ? 'Email auth success' : 'Email auth failed');
              },
              child: const Text('Email Login (Local)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final otp = await auth.sendMockOtp('+155500000');
                setState(() => status = 'Mock OTP generated: $otp');
              },
              child: const Text('Phone Login (Mock OTP)'),
            ),
            const SizedBox(height: 20),
            Text(status),
          ],
        ),
      ),
    );
  }
}
