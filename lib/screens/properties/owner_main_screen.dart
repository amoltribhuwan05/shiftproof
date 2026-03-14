import 'package:flutter/material.dart';
import 'package:shiftproof/screens/dashboard/property_dashboard_screen.dart';
import 'package:shiftproof/screens/payments/collections_screen.dart';
import 'package:shiftproof/screens/profile/profile_screen.dart';
import 'package:shiftproof/screens/properties/my_properties_screen.dart';
import 'package:shiftproof/widgets/nav/owner_bottom_nav.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PropertyDashboardScreen(),
    const MyPropertiesScreen(),
    const CollectionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: OwnerBottomNav(
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
