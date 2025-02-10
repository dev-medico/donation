class ExpensesRecord {
  final String id;
  final int? amount;
  final DateTime? date;
  final String? description;
  final String? category;
  final String? paymentMethod;

  ExpensesRecord({
    required this.id,
    this.amount,
    this.date,
    this.description,
    this.category,
    this.paymentMethod,
  });

  factory ExpensesRecord.fromJson(Map<String, dynamic> json) {
    return ExpensesRecord(
      id: json['_id'] as String,
      amount: json['amount'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      description: json['description'] as String?,
      category: json['category'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'date': date?.toIso8601String(),
      'description': description,
      'category': category,
      'paymentMethod': paymentMethod,
    };
  }

  ExpensesRecord copyWith({
    String? id,
    int? amount,
    DateTime? date,
    String? description,
    String? category,
    String? paymentMethod,
  }) {
    return ExpensesRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
 