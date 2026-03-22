import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/providers/user_provider.dart';
import 'package:shiftproof/screens/dashboard/property_dashboard_screen.dart';
import 'package:shiftproof/screens/dashboard/tenant_dashboard_screen.dart';
import 'package:shiftproof/screens/payments/collections_screen.dart';
import 'package:shiftproof/screens/payments/payment_history_screen.dart';
import 'package:shiftproof/screens/profile/profile_screen.dart';
import 'package:shiftproof/screens/properties/my_properties_screen.dart';
import 'package:shiftproof/screens/tenant/find_pg_screen.dart';
import 'package:shiftproof/widgets/nav/app_bottom_nav.dart';

class TenantMainScreen extends ConsumerStatefulWidget {
  const TenantMainScreen({super.key});

  @override
  ConsumerState<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends ConsumerState<TenantMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tenantScreens = [
    const FindPgScreen(),
    const TenantDashboardScreen(),
    const PaymentHistoryScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _ownerScreens = [
    const PropertyDashboardScreen(),
    const MyPropertiesScreen(),
    const CollectionsScreen(),
    const ProfileScreen(),
  ];

  // Track previous context to detect mode switches and reset tab index.
  bool? _prevIsOwnerContext;

  @override
  Widget build(BuildContext context) {
    // Watch the full provider — notifyListeners() from setContext() triggers rebuild.
    final userState = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);
    final isOwnerContext = notifier.isOwnerContext;
    final userSnapshot = userState.valueOrNull;

    // Reset to tab 0 whenever the mode switches.
    if (_prevIsOwnerContext != null && _prevIsOwnerContext != isOwnerContext) {
      _currentIndex = 0;
    }
    _prevIsOwnerContext = isOwnerContext;

    final screens = isOwnerContext ? _ownerScreens : _tenantScreens;
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: safeIndex,
        isOwnerContext: isOwnerContext,
        userImageUrl: userSnapshot?.avatarUrl,
        userInitial: userSnapshot?.name?.isNotEmpty ?? false
            ? userSnapshot!.name![0].toUpperCase()
            : null,
        userId: userSnapshot?.id,
        userGender: userSnapshot?.gender,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
