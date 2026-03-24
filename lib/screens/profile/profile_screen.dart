import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/providers/user_provider.dart';
import 'package:shiftproof/screens/profile/settings_screen.dart';
import 'package:shiftproof/services/auth_service.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/owner_onboarding_card.dart';
import 'package:shiftproof/widgets/cards/profile_menu_card.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AuthService _authService = AuthService.instance;

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _authService.signOut();
        if (mounted) {
          ref.read(userNotifierProvider.notifier).clearUser();
          unawaited(Navigator.pushNamedAndRemoveUntil(
            context,
            '/signin',
            (route) => false,
          ));
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    
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
      body: userState.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user data'));
          
          final isOwnerContext = userNotifier.isOwnerContext;

          return RefreshIndicator(
            onRefresh: userNotifier.refreshUser,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(context, user),

                    const SizedBox(height: 32),
                    if (user.isOwner && user.isTenant)
                      _buildModeSwitcher(context, isOwnerContext, userNotifier)
                    else if (!user.isOwner)
                      OwnerOnboardingCard(
                        onActionPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Onboarding flow coming soon!'),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Tenant mode view or shared sections
                    if (!isOwnerContext) ...[
                      _buildSectionHeader(context, 'TENANT SERVICES'),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.vpn_key_outlined,
                            title: 'My Stay',
                            subtitle: 'View current lease and maintenance',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            ),
                          ),
                          ProfileMenuItem(
                            icon: Icons.payments_outlined,
                            title: 'Payments',
                            subtitle: 'Rent and utility bills',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Management Mode View
                    if (isOwnerContext && user.isOwner) ...[
                      _buildSectionHeader(context, 'OWNER DASHBOARD'),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.domain,
                            title: 'Manage Properties',
                            subtitle: 'Manage your listings',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            ),
                          ),
                          ProfileMenuItem(
                            icon: Icons.analytics_outlined,
                            title: 'Reports & Revenue',
                            subtitle: 'Insights and performance',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(context, 'ACCOUNT FINANCE'),
                      ProfileMenuCard(
                        items: [
                          ProfileMenuItem(
                            icon: Icons.subscriptions_outlined,
                            title: 'Subscription Plan',
                            subtitle: 'Manage owner plan',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

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
                          onTap: _handleSignOut,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'ONE ACCOUNT. MULTIPLE ROLES.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'v1.0.0 • ShiftProof Real Estate',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => _buildShimmerBody(context),
        error: (e, s) => _buildErrorState(context, userNotifier.refreshUser),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final avatarSize =
        (MediaQuery.of(context).size.width * 0.24).clamp(72.0, 96.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
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
                        placeholder: (context, url) =>
                            _buildShimmerCircle(avatarSize),
                        errorWidget: (context, url, error) =>
                            _buildDefaultAvatar(user, isDark, theme),
                      )
                    : _buildDefaultAvatar(user, isDark, theme),
              ),
            ),
            if (user.profileCompleted)
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
        Text(user.email ?? user.phoneNumber ?? 'No Identifier',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              user.roles.map((role) => _buildRoleBadge(context, role)).toList(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => _EditProfileSheet(
                user: user,
                onSaved: () =>
                    ref.read(userNotifierProvider.notifier).refreshUser(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleBadge(BuildContext context, String role) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(AppUser user, bool isDark, ThemeData theme) {
    var sprite = DiceBearSprite.personas;
    if (user.gender != null) {
      final gender = user.gender!.toLowerCase();
      if (gender == 'male') {
        sprite = DiceBearSprite.avataaars;
      } else if (gender == 'female') {
        sprite = DiceBearSprite.lorelei;
      }
    }

    final avatar = DiceBearBuilder(
      seed: user.id,
      sprite: sprite,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
    ).build();

    return avatar.toImage(
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => Container(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: Text(
          user.name?.isNotEmpty ?? false ? user.name![0].toUpperCase() : 'U',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildShimmerHeader(context),
          const SizedBox(height: 40),
          _buildShimmerCard(context),
          const SizedBox(height: 24),
          _buildShimmerCard(context),
        ],
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
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300]!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildErrorState(BuildContext context, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text('An error occurred loading profile'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(BuildContext context, bool isOwnerContext, UserNotifier notifier) {
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
              isSelected: !isOwnerContext,
              onTap: () => notifier.setContext(UserContext.tenant),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context,
              title: 'Management',
              isSelected: isOwnerContext,
              onTap: () => notifier.setContext(UserContext.owner),
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
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
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

// ─── Edit Profile Bottom Sheet ────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.user, required this.onSaved});
  final AppUser user;
  final VoidCallback onSaved;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _areaController;
  String? _selectedGender;
  bool _isLoading = false;

  // label → API enum value
  static const _genders = [
    ('Male', 'MALE'),
    ('Female', 'FEMALE'),
    ('Other', 'CO_LIVING'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.name ?? '');
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');
    _cityController =
        TextEditingController(text: widget.user.city ?? '');
    _areaController =
        TextEditingController(text: widget.user.area ?? '');
    final gender = widget.user.gender;
    if (gender != null) {
      _selectedGender = _genders
          .map((e) => e.$2)
          .firstWhere((v) => v == gender, orElse: () => gender);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(profileServiceProvider).updateProfile(
            name: _nameController.text.trim(),
            gender: _selectedGender,
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            area: _areaController.text.trim().isEmpty
                ? null
                : _areaController.text.trim(),
          );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Full Name'),
            _field(controller: _nameController, hint: 'Your name'),
            const SizedBox(height: 14),

            _label('Gender'),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              hint: const Text('Select gender'),
              decoration: _inputDecoration(colorScheme),
              items: _genders
                  .map((e) => DropdownMenuItem(value: e.$2, child: Text(e.$1)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: 14),

            _label('Phone Number'),
            _field(
              controller: _phoneController,
              hint: '+91 9000000000',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _label('City'),
            _field(controller: _cityController, hint: 'e.g. Bangalore'),
            const SizedBox(height: 14),

            _label('Area / Locality'),
            _field(
                controller: _areaController,
                hint: 'e.g. Koramangala'),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _handleSave,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isLoading ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _inputDecoration(Theme.of(context).colorScheme)
            .copyWith(hintText: hint),
      );

  InputDecoration _inputDecoration(ColorScheme cs) => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}
