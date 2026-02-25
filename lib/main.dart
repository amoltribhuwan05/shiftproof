import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/get_started_screen.dart';

void main() {
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
      home: const InitialRouteHandler(),
    );
  }
}

class InitialRouteHandler extends StatelessWidget {
  const InitialRouteHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shiftproof Prototype')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Shiftproof',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
