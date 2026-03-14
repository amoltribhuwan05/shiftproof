import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/screens/profile/settings_screen.dart';
import 'package:shiftproof/screens/tenant/tenant_main_screen.dart';
import 'package:shiftproof/services/user_service.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/owner_onboarding_card.dart';
import 'package:shiftproof/widgets/cards/profile_menu_card.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  AppUser? _user;
  bool _isLoading = true;
  String? _error;
  bool _isManagementMode = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final user = await _userService.getMe();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          // Set management mode if owner, but keep tenant as default view
          // unless you want to default to management if they are an owner.
          // Based on brainstorming, tenant is default for everyone.
          _isManagementMode = false;
        });
      }
    } on Exception catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load profile. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        actions: const [NotificationBellButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                if (_isLoading)
                  _buildShimmerHeader(context)
                else if (_error != null)
                  _buildErrorState(context)
                else ...[
                  _buildProfileHeader(context, _user!),

                  // Ownership Status / Onboarding / Mode Switcher
                  const SizedBox(height: 32),
                  if (_user!.isOwner)
                    _buildModeSwitcher(context)
                  else
                    OwnerOnboardingCard(
                      onActionPressed: () {
                        // In a real app, navigate to ownership registration
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding flow coming soon!'),
                          ),
                        );
                      },
                    ),
                ],

                if (_user != null) ...[
                  const SizedBox(height: 32),

                  // Tenant Mode View
                  if (!_isManagementMode) ...[
                    _buildSectionHeader(context, 'TENANT SERVICES'),
                    ProfileMenuCard(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.vpn_key_outlined,
                          title: 'My Stay',
                          subtitle: 'View current lease and maintenance',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],

                  // Management Mode View
                  if (_isManagementMode && _user!.isOwner) ...[
                    _buildSectionHeader(context, 'OWNER DASHBOARD'),
                    ProfileMenuCard(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.domain,
                          title: 'Manage Properties',
                          subtitle: 'Manage your listings',
                          onTap: () {},
                        ),
                        ProfileMenuItem(
                          icon: Icons.analytics_outlined,
                          title: 'Performance',
                          subtitle: 'Monthly revenue and insights',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'ACCOUNT FINANCE'),
                    ProfileMenuCard(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.payments_outlined,
                          title: 'Subscription & Billing',
                          subtitle: 'Manage your payments',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // General Section - Always visible
                  _buildSectionHeader(context, 'GENERAL'),
                  ProfileMenuCard(
                    items: [
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Privacy, notifications, and app preferences',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        isDestructive: true,
                        onTap: () {
                          // In a real app, sign out from AuthService here
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const TenantMainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                Text(
                  'ONE ACCOUNT. MULTIPLE ROLES.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0 • ShiftProof Real Estate',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmerCircle(96),
                        errorWidget: (context, url, error) =>
                            _buildDefaultAvatar(user, isDark, theme),
                      )
                    : _buildDefaultAvatar(user, isDark, theme),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: theme.colorScheme.onPrimary,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name ?? 'No Name',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(user.email ?? 'No Email', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.role?.toUpperCase() ?? 'MEMBER',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(AppUser user, bool isDark, ThemeData theme) {
    final name = user.name ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildShimmerHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchProfile, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.cardColor
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              context,
              title: 'Personal Stay',
              isSelected: !_isManagementMode,
              onTap: () => setState(() => _isManagementMode = false),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context,
              title: 'Management',
              isSelected: _isManagementMode,
              onTap: () => setState(() => _isManagementMode = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
