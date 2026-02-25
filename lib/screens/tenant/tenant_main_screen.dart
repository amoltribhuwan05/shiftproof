import 'package:flutter/material.dart';
import '../dashboard/tenant_dashboard_screen.dart';
import '../tenant/find_pg_screen.dart';
import '../payments/payment_history_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/nav/app_bottom_nav.dart';

class TenantMainScreen extends StatefulWidget {
  const TenantMainScreen({super.key});

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FindPgScreen(),
    const TenantDashboardScreen(),
    const PaymentHistoryScreen(), // Using as placeholder for 'Saved'
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
