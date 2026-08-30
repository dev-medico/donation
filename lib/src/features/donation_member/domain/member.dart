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
  final String? profileUrl;
  final bool? canDonateValue;

  /// Whether staff have manually left donation permission switched on.
  ///
  /// The database stores this as a legacy status string. Recent-donation
  /// eligibility is intentionally calculated separately so it cannot overwrite
  /// the staff-controlled switch.
  bool get canDonate {
    if (canDonateValue != null) return canDonateValue!;
    final normalized = (status ?? 'available').trim().toLowerCase();
    return !const {
      'not_available',
      'unavailable',
      'disabled',
      'false',
      '0',
    }.contains(normalized);
  }

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
    this.profileUrl,
    this.canDonateValue,
  });

  /// Returns a copy with only the staff-editable availability fields replaced.
  ///
  /// Search rows carry the server-derived effective last donation date in
  /// [lastDate], so an edit must never copy that (or any other field) from the
  /// raw member record the update endpoint returns.
  Member withAvailability({
    required String? status,
    required String? note,
    required bool? canDonateValue,
  }) {
    return Member(
      id: id,
      memberId: memberId,
      name: name,
      fatherName: fatherName,
      bloodType: bloodType,
      phone: phone,
      nrc: nrc,
      address: address,
      gender: gender,
      birthDate: birthDate,
      bloodBankCard: bloodBankCard,
      note: note,
      status: status,
      lastDate: lastDate,
      registerDate: registerDate,
      memberCount: memberCount,
      totalCount: totalCount,
      profileUrl: profileUrl,
      canDonateValue: canDonateValue,
    );
  }

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
      profileUrl: json['profile_url'],
      canDonateValue: _parseBoolean(json['can_donate']),
    );
  }

  static bool? _parseBoolean(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }
    return null;
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
      'profile_url': profileUrl,
    };
  }
}
