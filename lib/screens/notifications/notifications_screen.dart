import 'package:flutter/material.dart';
import '../../widgets/cards/notification_card.dart';
import '../../data/services/mock_api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> _notifications;

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'rentDue':
        return NotificationType.rentDue;
      case 'message':
        return NotificationType.newMessage;
      case 'maintenance':
        return NotificationType.maintenanceRequest;
      case 'leaseRenewal':
        return NotificationType.leaseRenewal;
      default:
        return NotificationType.general;
    }
  }

  static DateTime _parseTimestamp(String ts) {
    final now = DateTime.now();
    if (ts.contains('m ago')) {
      final mins = int.tryParse(ts.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return now.subtract(Duration(minutes: mins));
    } else if (ts.contains('h ago')) {
      final hrs = int.tryParse(ts.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return now.subtract(Duration(hours: hrs));
    } else if (ts.contains('d ago')) {
      final days = int.tryParse(ts.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return now.subtract(Duration(days: days));
    }
    return now;
  }

  @override
  void initState() {
    super.initState();
    _notifications = MockApiService.getNotifications()
        .map(
          (n) => NotificationItem(
            id: n.id,
            type: _typeFromString(n.type),
            title: n.title,
            description: n.description,
            timestamp: _parseTimestamp(n.timestamp),
            isRead: n.isRead,
          ),
        )
        .toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map(
            (n) => NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              description: n.description,
              timestamp: n.timestamp,
              isRead: true,
            ),
          )
          .toList();
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_unreadCount',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return NotificationCard(
                  notification: notif,
                  onTap: () {
                    // Mark as read on tap
                    setState(() {
                      _notifications[index] = NotificationItem(
                        id: notif.id,
                        type: notif.type,
                        title: notif.title,
                        description: notif.description,
                        timestamp: notif.timestamp,
                        isRead: true,
                      );
                    });
                  },
                  onDismiss: () => _removeNotification(notif.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications right now.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
