class Member {
  final String? id;
  final String? memberId;
  final String? name;
  final String? phone;
  final String? bloodType;
  final String? birthDate;
  final String? address;
  final int? totalCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({
    this.id,
    this.memberId,
    this.name,
    this.phone,
    this.bloodType,
    this.birthDate,
    this.address,
    this.totalCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String?,
      memberId: json['member_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      bloodType: json['blood_type'] as String?,
      birthDate: json['birth_date'] as String?,
      address: json['address'] as String?,
      totalCount: json['total_count'] as int?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'name': name,
      'phone': phone,
      'blood_type': bloodType,
      'birth_date': birthDate,
      'address': address,
      'total_count': totalCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 