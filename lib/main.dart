import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/theme/app_theme.dart';
import 'package:shiftproof/firebase_options.dart';
import 'package:shiftproof/providers/user_provider.dart';
import 'package:shiftproof/screens/auth/email_registration_screen.dart';
import 'package:shiftproof/screens/auth/forgot_password_screen.dart';
import 'package:shiftproof/screens/auth/login_screen.dart';
import 'package:shiftproof/screens/auth/onboarding_screen.dart';
import 'package:shiftproof/screens/auth/phone_login_screen.dart';
import 'package:shiftproof/screens/payments/pay_bill_screen.dart';
import 'package:shiftproof/screens/properties/owner_main_screen.dart';
import 'package:shiftproof/screens/tenant/join_pg_screen.dart';
import 'package:shiftproof/screens/tenant/tenant_main_screen.dart';
import 'package:shiftproof/widgets/network/connection_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Attempting Firebase Init...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Initialized Successfully.');
  } on Exception catch (e, stack) {
    debugPrint('Firebase init failed: $e');
    debugPrintStack(stackTrace: stack);
  }
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } on Exception catch (e) {
    debugPrint('Failed to set orientation: $e');
  }

  runApp(const ProviderScope(child: ShiftproofApp()));
}

class ShiftproofApp extends ConsumerWidget {
  const ShiftproofApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);

    return MaterialApp(
      title: 'Shiftproof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routes: {
        '/home': (context) => const TenantMainScreen(),
        '/signup': (context) => const EmailRegistrationScreen(),
        '/signin': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/phone-login': (context) => const PhoneLoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/join-pg': (context) => const JoinPgScreen(),
        '/pay-bill': (context) => const PayBillScreen(),
      },
      builder: (context, child) {
        return ConnectionWrapper(child: child!);
      },
      home: userState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          }
          if (!user.profileCompleted) {
            return const OnboardingScreen();
          }
          if (user.isOwner && !user.isTenant) {
            return const OwnerMainScreen();
          }
          return const TenantMainScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to load user state'),
                TextButton(
                  onPressed: () => ref.refresh(userNotifierProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
