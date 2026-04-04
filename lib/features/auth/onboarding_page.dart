import 'package:duobloom_mobile/app/providers.dart';
import 'package:duobloom_mobile/core/widgets/common_widgets.dart';
import 'package:duobloom_mobile/data/models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Aarav');
  final _partnerController = TextEditingController(text: 'Mira');
  final _relationshipController =
      TextEditingController(text: 'Growing together');
  final _partnerCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  AuthMethod _authMethod = AuthMethod.email;
  DateTime _sinceDate = DateTime.now().subtract(const Duration(days: 196));
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _partnerController.dispose();
    _relationshipController.dispose();
    _partnerCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickSinceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sinceDate,
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _sinceDate = picked);
    }
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('Enter a phone number first.');
      return;
    }

    final code = await ref.read(appControllerProvider.notifier).requestMockOtp(phone);
    if (!mounted) {
      return;
    }
    _showMessage('Mock OTP for demo: $code');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_authMethod == AuthMethod.phone) {
      final verified = await ref.read(appControllerProvider.notifier).verifyMockOtp(
            phone: _phoneController.text,
            otp: _otpController.text,
          );
      if (!verified) {
        _showMessage('The mock OTP is invalid or expired.');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      await ref.read(appControllerProvider.notifier).completeOnboarding(
            OnboardingData(
              name: _nameController.text,
              partnerName: _partnerController.text,
              relationshipLabel: _relationshipController.text,
              sinceDate: _sinceDate,
              authMethod: _authMethod,
              partnerCode: _partnerCodeController.text,
              email: _authMethod == AuthMethod.email ? _emailController.text : null,
              phone: _authMethod == AuthMethod.phone ? _phoneController.text : null,
              password:
                  _authMethod == AuthMethod.email ? _passwordController.text : null,
            ),
          );
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AmbientPage(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'DB',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('DuoBloom', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'A local-first shared routine space for two people who want habits, growth, memories, and wellbeing in one calm flow.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        StatPill(label: 'Storage', value: 'Local SQLite'),
                        StatPill(label: 'Backup', value: 'Encrypted'),
                        StatPill(label: 'Cloud', value: 'Media only'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Set up the couple space',
                      subtitle:
                          'Choose the local login style first, then personalize both profiles.',
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<AuthMethod>(
                      segments: const [
                        ButtonSegment(
                          value: AuthMethod.email,
                          label: Text('Email'),
                          icon: Icon(Icons.mail_outline_rounded),
                        ),
                        ButtonSegment(
                          value: AuthMethod.phone,
                          label: Text('Phone'),
                          icon: Icon(Icons.phone_android_rounded),
                        ),
                      ],
                      selected: {_authMethod},
                      onSelectionChanged: (values) {
                        setState(() => _authMethod = values.first);
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Your name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _partnerController,
                      decoration: const InputDecoration(labelText: 'Partner name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _relationshipController,
                      decoration: const InputDecoration(labelText: 'Shared label'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickSinceDate,
                      borderRadius: BorderRadius.circular(20),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Days together start date',
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              '${_sinceDate.day}/${_sinceDate.month}/${_sinceDate.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _partnerCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Optional partner import code',
                        helperText: 'Use this later if you import the partner profile bundle.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _buildAuthFields(),
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: _submitting ? 'Creating your space...' : 'Create DuoBloom',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthFields() {
    switch (_authMethod) {
      case AuthMethod.email:
        return Column(
          key: const ValueKey('email'),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) {
                if (_authMethod != AuthMethod.email) {
                  return null;
                }
                return value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Local password'),
              validator: (value) {
                if (_authMethod != AuthMethod.email) {
                  return null;
                }
                return value == null || value.length < 6
                    ? 'Minimum 6 characters'
                    : null;
              },
            ),
          ],
        );
      case AuthMethod.phone:
        return Column(
          key: const ValueKey('phone'),
          children: [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile number'),
              validator: (value) {
                if (_authMethod != AuthMethod.phone) {
                  return null;
                }
                return value == null || value.trim().length < 8
                    ? 'Enter a valid number'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Mock OTP'),
                    validator: (value) {
                      if (_authMethod != AuthMethod.phone) {
                        return null;
                      }
                      return value == null || value.trim().length != 6
                          ? '6-digit OTP'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 126,
                  child: OutlinedButton(
                    onPressed: _requestOtp,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ],
        );
      case AuthMethod.google:
        return const SizedBox.shrink();
    }
  }
}
