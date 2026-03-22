import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/cards/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static NotificationType _typeFromString(String? type) {
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

  static DateTime _parseTimestamp(String? ts) {
    if (ts == null) return DateTime.now();
    return DateTime.tryParse(ts) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(theme, unreadCount: 0, onMarkAll: null),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _buildAppBar(theme, unreadCount: 0, onMarkAll: null),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load notifications'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (apiNotifications) {
        // Map API model to NotificationCard's expected NotificationItem
        final items = apiNotifications
            .map(
              (n) => NotificationItem(
                id: n.id ?? '',
                type: _typeFromString(n.type),
                title: n.title ?? '',
                description: n.description ?? '',
                timestamp: _parseTimestamp(n.timestamp),
                isRead: n.isRead ?? false,
              ),
            )
            .toList();

        final unreadCount = items.where((n) => !n.isRead).length;

        return _NotificationsBody(
          items: items,
          unreadCount: unreadCount,
          onMarkAll: () async {
            await ref.read(notificationServiceProvider).markAllNotificationsRead();
            ref.invalidate(notificationsProvider);
          },
          onMarkRead: (id) async {
            await ref.read(notificationServiceProvider).markNotificationRead(id);
            ref.invalidate(notificationsProvider);
          },
        );
      },
    );
  }

  AppBar _buildAppBar(
    ThemeData theme, {
    required int unreadCount,
    required VoidCallback? onMarkAll,
  }) {
    return AppBar(
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
          if (unreadCount > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount',
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
        if (unreadCount > 0 && onMarkAll != null)
          TextButton(
            onPressed: onMarkAll,
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
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  const _NotificationsBody({
    required this.items,
    required this.unreadCount,
    required this.onMarkAll,
    required this.onMarkRead,
  });

  final List<NotificationItem> items;
  final int unreadCount;
  final Future<void> Function() onMarkAll;
  final Future<void> Function(String id) onMarkRead;

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(widget.items);
  }

  @override
  void didUpdateWidget(_NotificationsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _notifications = List.of(widget.items);
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationItem(
                id: n.id,
                type: n.type,
                title: n.title,
                description: n.description,
                timestamp: n.timestamp,
                isRead: true,
              ))
          .toList();
    });
    widget.onMarkAll();
  }

  void _markRead(int index) {
    final notif = _notifications[index];
    if (notif.isRead) return;
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
    widget.onMarkRead(notif.id);
  }

  void _remove(String id) {
    setState(() => _notifications.removeWhere((n) => n.id == id));
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
                  onTap: () => _markRead(index),
                  onDismiss: () => _remove(notif.id),
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
