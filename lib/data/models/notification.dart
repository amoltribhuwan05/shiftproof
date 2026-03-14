class AppNotification {
  final String? id;
  final String? description;
  final bool? isRead;
  final String? timestamp;
  final String? title;
  final String? type;

  const AppNotification({
    this.id,
    this.description,
    this.isRead,
    this.timestamp,
    this.title,
    this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String?,
      description: json['description'] as String?,
      isRead: json['isRead'] as bool?,
      timestamp: json['timestamp'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (isRead != null) 'isRead': isRead,
      if (timestamp != null) 'timestamp': timestamp,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
    };
  }
}
