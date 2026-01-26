class MemberRange {
  final String start;
  final String end;
  final String label;
  final int count;

  MemberRange({
    required this.start,
    required this.end,
    required this.label,
    required this.count,
  });

  factory MemberRange.fromJson(Map<String, dynamic> json) {
    return MemberRange(
      start: json['start'] as String,
      end: json['end'] as String,
      label: json['label'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'label': label,
      'count': count,
    };
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
