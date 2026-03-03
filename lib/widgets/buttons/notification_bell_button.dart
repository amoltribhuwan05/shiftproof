import 'package:flutter/material.dart';
import '../../screens/notifications/notifications_screen.dart';

/// A reusable notification bell icon button for app bars.
/// Shows a colored dot indicator when [hasUnread] is true.
class NotificationBellButton extends StatelessWidget {
  final bool hasUnread;
  final Color? dotColor;

  const NotificationBellButton({
    super.key,
    this.hasUnread = true,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedDotColor = dotColor ?? Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: isDark ? Colors.white : Colors.black87,
          ),
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
        ),
        if (hasUnread)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: resolvedDotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
