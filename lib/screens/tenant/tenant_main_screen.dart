import 'package:flutter/material.dart';
import '../dashboard/tenant_dashboard_screen.dart';
import '../tenant/find_pg_screen.dart';
import '../payments/payment_history_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/nav/app_bottom_nav.dart';
import '../../services/user_service.dart';
import '../../data/models/models.dart';

class TenantMainScreen extends StatefulWidget {
  const TenantMainScreen({super.key});

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _currentIndex = 0;
  final UserService _userService = UserService();
  AppUser? _user;

  final List<Widget> _screens = [
    const FindPgScreen(),
    const TenantDashboardScreen(),
    const PaymentHistoryScreen(), // Using as placeholder for 'Saved'
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userService.getMe();
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user for bottom nav: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        userImageUrl: _user?.avatarUrl,
        userInitial: _user?.name?.isNotEmpty == true ? _user!.name![0].toUpperCase() : null,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
