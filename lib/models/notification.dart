class Notification {
  final String id;
  final String? title;
  final String? body;
  final String? payload;
  final DateTime? createdAt;

  Notification({
    required this.id,
    this.title,
    this.body,
    this.payload,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      payload: json['payload'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? payload,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 