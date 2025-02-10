class DonarRecord {
  final String id;
  final int? amount;
  final DateTime? date;
  final String? name;

  DonarRecord({
    required this.id,
    this.amount,
    this.date,
    this.name,
  });

  factory DonarRecord.fromJson(Map<String, dynamic> json) {
    return DonarRecord(
      id: json['_id'] as String,
      amount: json['amount'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'date': date?.toIso8601String(),
      'name': name,
    };
  }

  DonarRecord copyWith({
    String? id,
    int? amount,
    DateTime? date,
    String? name,
  }) {
    return DonarRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      name: name ?? this.name,
    );
  }
} 