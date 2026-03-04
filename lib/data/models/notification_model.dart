class AppNotification {
  final String id;
  final String title;
  final String description;

  /// Notification category: 'rentDue' | 'message' | 'maintenance' | 'leaseRenewal' | 'general'
  final String type;

  /// ISO 8601 timestamp string (e.g. "2026-03-05T22:00:00Z").
  /// Use DateTime.parse(timestamp) for calculating relative time in UI.
  /// NEVER store a pre-formatted string like "2h ago" — format in the UI layer.
  final String timestamp;

  /// Whether the user has read this notification.
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  /// Returns a new instance with [isRead] set to true.
  AppNotification markAsRead() => AppNotification(
    id: id,
    title: title,
    description: description,
    type: type,
    timestamp: timestamp,
    isRead: true,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool,
    );
  }
}
