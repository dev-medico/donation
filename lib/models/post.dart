import 'package:donation/models/member.dart';

class Post {
  final String id;
  final String? text;
  final List<String> images;
  final List<Reaction> reactions;
  final List<Comment> comments;
  final DateTime? createdAt;
  final String? postedBy;
  final String? posterProfileUrl;

  Post({
    required this.id,
    this.text,
    required this.images,
    required this.reactions,
    required this.comments,
    this.createdAt,
    this.postedBy,
    this.posterProfileUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String,
      text: json['text'] as String?,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      reactions: (json['reactions'] as List<dynamic>)
          .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      postedBy: json['postedBy'] as String?,
      posterProfileUrl: json['posterProfileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'images': images,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'postedBy': postedBy,
      'posterProfileUrl': posterProfileUrl,
    };
  }

  Post copyWith({
    String? id,
    String? text,
    List<String>? images,
    List<Reaction>? reactions,
    List<Comment>? comments,
    DateTime? createdAt,
    String? postedBy,
    String? posterProfileUrl,
  }) {
    return Post(
      id: id ?? this.id,
      text: text ?? this.text,
      images: images ?? this.images,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      postedBy: postedBy ?? this.postedBy,
      posterProfileUrl: posterProfileUrl ?? this.posterProfileUrl,
    );
  }
}

class Reaction {
  final String id;
  final String? emoji;
  final String? type;
  final Member? member;
  final DateTime? createdAt;

  Reaction({
    required this.id,
    this.emoji,
    this.type,
    this.member,
    this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['_id'] as String,
      emoji: json['emoji'] as String?,
      type: json['type'] as String?,
      member: json['member'] != null ? Member.fromJson(json['member'] as Map<String, dynamic>) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'emoji': emoji,
      'type': type,
      'member': member?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Reaction copyWith({
    String? id,
    String? emoji,
    String? type,
    Member? member,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      member: member ?? this.member,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Comment {
  final String id;
  final String? text;
  final Member? member;
  final List<Reaction> reactions;
  final List<Comment> comments;
  final DateTime? createdAt;

  Comment({
    required this.id,
    this.text,
    this.member,
    required this.reactions,
    required this.comments,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] as String,
      text: json['text'] as String?,
      member: json['member'] != null ? Member.fromJson(json['member'] as Map<String, dynamic>) : null,
      reactions: (json['reactions'] as List<dynamic>)
          .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'member': member?.toJson(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? text,
    Member? member,
    List<Reaction>? reactions,
    List<Comment>? comments,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      member: member ?? this.member,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 