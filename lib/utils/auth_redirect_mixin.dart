import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/providers/user_provider.dart';
import 'package:shiftproof/services/auth_service.dart';

/// Shared mixin for post-authentication navigation logic.
/// After sign-in, refreshes the user provider then redirects to
/// '/onboarding' or '/home' accordingly.
mixin AuthRedirectMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<void> checkOnboardingAndRedirect() async {
    try {
      final userProfile = await AuthService.instance.getMe();
      if (!mounted) return;

      // Refresh the provider so all screens see the newly logged-in user.
      ref.invalidate(userNotifierProvider);

      if (userProfile.name == null || userProfile.name!.isEmpty) {
        unawaited(
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/onboarding',
            (route) => false,
          ),
        );
      } else {
        unawaited(
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        );
      }
    } on Exception {
      if (!mounted) return;
      ref.invalidate(userNotifierProvider);
      unawaited(
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        ),
      );
    }
  }
}
