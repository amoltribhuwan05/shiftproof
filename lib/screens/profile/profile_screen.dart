import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../widgets/cards/profile_menu_card.dart';
import '../tenant/tenant_main_screen.dart';
import 'settings_screen.dart';
import '../../data/services/mock_api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final user = MockApiService.getCurrentOwner();

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
        actions: [
          const NotificationBellButton(),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // User Profile Section
              const SizedBox(height: 24),
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
                      child: Image.network(
                        user.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  )
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.05,
                                  ),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
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
                user.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(user.email, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'PREMIUM MEMBER',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tenant Services Section
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
              const SizedBox(height: 24),

              // Owner Dashboard Section
              _buildSectionHeader(context, 'OWNER DASHBOARD'),
              ProfileMenuCard(
                items: [
                  ProfileMenuItem(
                    icon: Icons.domain,
                    title: 'Manage Properties',
                    subtitle: '8 active listings, 2 pending',
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

              // Account Finance
              _buildSectionHeader(context, 'ACCOUNT FINANCE'),
              ProfileMenuCard(
                items: [
                  ProfileMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Subscription & Billing',
                    subtitle: 'Visa ending in 4242',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // General Section
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
                        MaterialPageRoute(
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TenantMainScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                'ONE ACCOUNT. MULTIPLE ROLES.',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
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
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
