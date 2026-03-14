import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shiftproof/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shiftproof Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                unawaited(Navigator.pushReplacementNamed(context, '/signin'));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to Shiftproof!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
