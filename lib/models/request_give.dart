class RequestGive {
  final String id;
  final int? request;
  final int? give;
  final DateTime? date;

  RequestGive({
    required this.id,
    this.request,
    this.give,
    this.date,
  });

  factory RequestGive.fromJson(Map<String, dynamic> json) {
    return RequestGive(
      id: json['_id'] as String,
      request: json['request'] as int?,
      give: json['give'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'request': request,
      'give': give,
      'date': date?.toIso8601String(),
    };
  }

  RequestGive copyWith({
    String? id,
    int? request,
    int? give,
    DateTime? date,
  }) {
    return RequestGive(
      id: id ?? this.id,
      request: request ?? this.request,
      give: give ?? this.give,
      date: date ?? this.date,
    );
  }
} 