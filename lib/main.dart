import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/theme/app_theme.dart';
import 'package:shiftproof/firebase_options.dart';
import 'package:shiftproof/screens/auth/email_registration_screen.dart';
import 'package:shiftproof/screens/auth/login_screen.dart';
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

class ShiftproofApp extends StatelessWidget {
  const ShiftproofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiftproof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
