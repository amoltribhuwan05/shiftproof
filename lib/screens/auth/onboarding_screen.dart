import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/providers/user_provider.dart';
import 'package:shiftproof/widgets/auth/custom_text_field.dart';
import 'package:shiftproof/widgets/auth/primary_auth_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedGender;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Firebase (Google profile or display name)
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser?.displayName != null &&
        firebaseUser!.displayName!.isNotEmpty) {
      _nameController.text = firebaseUser.displayName!;
    }
    // Pre-fill phone if signed in via phone
    if (firebaseUser?.phoneNumber != null &&
        firebaseUser!.phoneNumber!.isNotEmpty) {
      _phoneController.text = firebaseUser.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_step1FormKey.currentState?.validate() ?? false) {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _handleCompleteProfile() async {
    if (!(_step2FormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(profileServiceProvider).completeOnboarding(
            name: _nameController.text.trim(),
            gender: _selectedGender!,
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            area: _areaController.text.trim().isEmpty
                ? null
                : _areaController.text.trim(),
          );
      // Refresh the user state so the app picks up the completed profile.
      await ref.read(userNotifierProvider.notifier).refreshUser();
      if (mounted) {
        unawaited(
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == 1
            ? BackButton(
                color: colorScheme.onSurface,
                onPressed: () => setState(() => _currentStep = 0),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              Row(
                children: [
                  _StepDot(active: _currentStep >= 0),
                  Expanded(
                    child: Divider(
                      color: _currentStep >= 1
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      thickness: 2,
                    ),
                  ),
                  _StepDot(active: _currentStep >= 1),
                ],
              ),
              const SizedBox(height: 32),

              if (_currentStep == 0) _buildStep1(theme) else _buildStep2(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'About You',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 1 of 2 — Tell us your name and gender.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'Full Name',
            hint: 'Enter your name',
            controller: _nameController,
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedGender, // ignore: deprecated_member_use -- DropdownButtonFormField has no initialValue; value is the correct reactive param
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: ['Male', 'Female', 'Other']
                .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) =>
                value == null ? 'Please select your gender.' : null,
          ),
          const SizedBox(height: 48),
          PrimaryAuthButton(
            text: 'Continue',
            onPressed: _goToStep2,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your Location',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 2 of 2 — Help us find properties near you.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'City',
            hint: 'e.g. Pune, Mumbai',
            controller: _cityController,
            prefixIcon: Icons.location_city_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your city.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Area (Optional)',
            hint: 'e.g. Koregaon Park',
            controller: _areaController,
            prefixIcon: Icons.map_outlined,
          ),
          const SizedBox(height: 48),
          PrimaryAuthButton(
            text: 'Complete Profile',
            onPressed: _handleCompleteProfile,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outlineVariant;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
