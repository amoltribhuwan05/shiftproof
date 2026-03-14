import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_registration_screen.dart';
import 'screens/tenant/tenant_main_screen.dart';
import 'widgets/network/connection_wrapper.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Attempting Firebase Init...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Initialized Successfully.');
  } catch (e, stack) {
    debugPrint('Firebase init failed: $e');
    debugPrintStack(stackTrace: stack);
  }
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Failed to set orientation: $e');
  }

  runApp(const ShiftproofApp());
}

class ShiftproofApp extends StatelessWidget {
  const ShiftproofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiftproof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically switches based on OS setting
      routes: {
        '/home': (context) => const TenantMainScreen(),
        '/signup': (context) => const EmailRegistrationScreen(),
        '/signin': (context) => const LoginScreen(),
      },
      builder: (context, child) {
        return ConnectionWrapper(child: child!);
      },
      home: const LoginScreen(),
    );
  }
}
