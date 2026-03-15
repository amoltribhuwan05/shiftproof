import 'package:cached_network_image/cached_network_image.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.userImageUrl,
    this.userInitial,
    this.userId,
    this.userGender,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? userImageUrl;
  final String? userInitial;
  final String? userId;
  final String? userGender;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.saved_search),
          label: 'Explore',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'My Stay',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: _buildProfileIcon(context, false),
          activeIcon: _buildProfileIcon(context, true),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildProfileIcon(BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasImage = userImageUrl != null && userImageUrl!.isNotEmpty;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? colorScheme.primary
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: userImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                errorWidget: (context, url, error) =>
                    _buildPersonalizedAvatar(theme),
              )
            : _buildPersonalizedAvatar(theme),
      ),
    );
  }

  Widget _buildPersonalizedAvatar(ThemeData theme) {
    final seed = userId ?? 'guest';
    var sprite = DiceBearSprite.personas;
    
    if (userGender != null) {
      final gender = userGender!.toLowerCase();
      if (gender == 'male') {
        sprite = DiceBearSprite.avataaars;
      } else if (gender == 'female') {
        sprite = DiceBearSprite.lorelei;
      }
    }

    final avatar = DiceBearBuilder(
      seed: seed,
      sprite: sprite,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
    ).build();

    return avatar.toImage(
      fit: BoxFit.cover,
      placeholderBuilder: (context) => _buildInitialFallback(theme),
    );
  }

  Widget _buildInitialFallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        userInitial ?? 'U',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
