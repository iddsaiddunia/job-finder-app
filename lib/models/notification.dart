class Notification {
  final int id;
  final String type;
  final String title;
  final String message;
  final int? relatedObjectId;
  final String? relatedObjectType;
  final DateTime createdAt;
  final String createdAtFormatted;
  bool isRead;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedObjectId,
    this.relatedObjectType,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.isRead,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['notification_type'],
      title: json['title'],
      message: json['message'],
      relatedObjectId: json['related_object_id'],
      relatedObjectType: json['related_object_type'],
      createdAt: DateTime.parse(json['created_at']),
      createdAtFormatted: json['created_at_formatted'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': type,
      'title': title,
      'message': message,
      'related_object_id': relatedObjectId,
      'related_object_type': relatedObjectType,
      'created_at': createdAt.toIso8601String(),
      'created_at_formatted': createdAtFormatted,
      'is_read': isRead,
    };
  }
}
