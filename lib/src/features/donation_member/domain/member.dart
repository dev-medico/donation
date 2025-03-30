class Member {
  final dynamic id;
  final String? memberId;
  final String? name;
  final String? fatherName;
  final String? bloodType;
  final String? phone;
  final String? nrc;
  final String? address;
  final String? gender;
  final String? birthDate;
  final String? bloodBankCard;
  final String? note;
  final String? status;
  final String? lastDate;
  final String? registerDate;
  final String? memberCount;
  final String? totalCount;

  Member({
    this.id,
    this.memberId,
    this.name,
    this.fatherName,
    this.bloodType,
    this.phone,
    this.nrc,
    this.address,
    this.gender,
    this.birthDate,
    this.bloodBankCard,
    this.note,
    this.status,
    this.lastDate,
    this.registerDate,
    this.memberCount,
    this.totalCount,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      memberId: json['member_id'],
      name: json['name'],
      fatherName: json['father_name'],
      bloodType: json['blood_type'],
      phone: json['phone'],
      nrc: json['nrc'],
      address: json['address'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      bloodBankCard: json['blood_bank_card'],
      note: json['note'],
      status: json['status'],
      lastDate: json['last_date'],
      registerDate: json['register_date'],
      memberCount: json['member_count'],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'name': name,
      'father_name': fatherName,
      'blood_type': bloodType,
      'phone': phone,
      'nrc': nrc,
      'address': address,
      'gender': gender,
      'birth_date': birthDate,
      'blood_bank_card': bloodBankCard,
      'note': note,
      'status': status,
      'last_date': lastDate,
      'register_date': registerDate,
      'member_count': memberCount,
      'total_count': totalCount,
    };
  }
}
