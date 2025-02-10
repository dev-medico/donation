import 'package:donation/models/member.dart';

class Message {
  final String id;
  final String? content;
  final Member? sender;
  final Member? receiver;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;

  Message({
    required this.id,
    this.content,
    this.sender,
    this.receiver,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String,
      content: json['content'] as String?,
      sender: json['sender'] != null
          ? Member.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      receiver: json['receiver'] != null
          ? Member.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentType: json['attachmentType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  Message copyWith({
    String? id,
    String? content,
    Member? sender,
    Member? receiver,
    String? attachmentUrl,
    String? attachmentType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
