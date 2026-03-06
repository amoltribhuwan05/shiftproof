import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/network/connection_wrapper.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Attempting Firebase Init...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase Initialized Successfully!');
  } catch (e, stack) {
    print('FIREBASE INIT ERROR: $e');
    print('STACKTRACE: $stack');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
      builder: (context, child) {
        return ConnectionWrapper(child: child!);
      },
      home: const LoginScreen(),
    );
  }
}
