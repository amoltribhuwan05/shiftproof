import 'package:flutter/material.dart';

/// Defines the type of notification, which controls its icon and color.
enum NotificationType {
  rentDue,
  newMessage,
  maintenanceRequest,
  leaseRenewal,
  general,
}

/// Data model for a single notification item.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
}

/// A card widget for displaying a single notification.
///
/// Follows the Stitch design spec:
/// - Color-coded icon in a circular background
/// - Bold title, two-line description
/// - Right-aligned timestamp
/// - Subtle unread dot indicator
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    super.key,
    this.onTap,
    this.onDismiss,
  });
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  // --- Static helpers for icon/color based on type ---

  static IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.rentDue:
        return Icons.receipt_long_rounded;
      case NotificationType.newMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.maintenanceRequest:
        return Icons.build_rounded;
      case NotificationType.leaseRenewal:
        return Icons.calendar_month_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  static Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.rentDue:
        return const Color(0xFFE53E3E); // Red
      case NotificationType.newMessage:
        return Colors.lightBlue; // Sky Blue (project primary)
      case NotificationType.maintenanceRequest:
        return const Color(0xFFED8936); // Orange
      case NotificationType.leaseRenewal:
        return const Color(0xFF38A169); // Green
      case NotificationType.general:
        return const Color(0xFF718096); // Grey
    }
  }

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${ts.day}/${ts.month}/${ts.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _colorForType(notification.type);
    final typeIcon = _iconForType(notification.type);

    final cardColor = isDark
        ? (notification.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withValues(alpha: 0.9))
        : (notification.isRead
              ? Colors.white
              : Colors.blue.shade50.withValues(alpha: 0.5));

    final borderColor = isDark
        ? (notification.isRead
              ? Colors.white.withValues(alpha: 0.06)
              : typeColor.withValues(alpha: 0.2))
        : (notification.isRead
              ? Colors.grey.shade200
              : typeColor.withValues(alpha: 0.15));

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Color-coded icon container ---
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: isDark ? 0.15 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 14),

                  // --- Content: title, description ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // --- Timestamp ---
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            height: 1.4,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Unread dot indicator ---
                  if (!notification.isRead)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
