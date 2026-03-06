import 'package:flutter/material.dart';

enum SocialProvider { google, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isGoogle = provider == SocialProvider.google;
    final text = isGoogle ? 'Continue with Google' : 'Continue with Apple';
    final iconData = isGoogle
        ? Icons.g_mobiledata
        : Icons.apple; // Use generic icons or assets if preferred

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(iconData, size: 28, color: theme.colorScheme.onSurface),
          label: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(color: theme.colorScheme.onSurface.withAlpha(51)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28), // 28dp for MD3
            ),
          ),
        ),
      ),
    );
  }
}
