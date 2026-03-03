class AppNotification {
  final String id;
  final String title;
  final String description;
  final String
  type; // 'rentDue', 'message', 'maintenance', 'leaseRenewal', 'general'
  final String timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

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
