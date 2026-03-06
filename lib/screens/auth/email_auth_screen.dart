import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/auth/custom_text_field.dart';
import '../../../../widgets/auth/primary_auth_button.dart';
import '../../../../widgets/auth/social_login_button.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // On success, auth stream/router should pick this up or we can push
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully Signed In')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on AuthException catch (e) {
        if (mounted) {
          if (e.code == 'invalid-credential' ||
              e.code == 'user-not-found' ||
              e.code == 'wrong-password') {
            Navigator.pushNamed(
              context,
              '/signup',
              arguments: {
                'email': _emailController.text.trim(),
                'password': _passwordController.text.trim(),
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your Shiftproof account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface.withAlpha(
                      153,
                    ), // 0.6 opacity
                  ),
                ),
                const SizedBox(height: 48),

                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    }
                    if (!value.contains('@')) return 'Enter a valid email.';
                    return null;
                  },
                ),

                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot Password flow
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                PrimaryAuthButton(
                  text: 'Continue',
                  onPressed: _handleSignIn,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.onSurface.withAlpha(51),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(128),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.onSurface.withAlpha(51),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SocialLoginButton(
                  provider: SocialProvider.google,
                  onPressed: () {}, // Optional Google Auth
                ),
                SocialLoginButton(
                  provider: SocialProvider.apple,
                  onPressed: () {}, // Optional Apple Auth
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
