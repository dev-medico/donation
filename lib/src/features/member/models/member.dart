class Member {
  final String? id;
  final String? name;
  final String? bloodType;
  final String? dateOfBirth;
  final String? phone;
  final String? address;
  final String? block;
  final String? email;
  final String? township;
  final String? gender;
  final String? nrcNo;
  final String? remark;
  final String? profileImage;
  final String? createdAt;
  final String? updatedAt;

  Member({
    this.id,
    this.name,
    this.bloodType,
    this.dateOfBirth,
    this.phone,
    this.address,
    this.block,
    this.email,
    this.township,
    this.gender,
    this.nrcNo,
    this.remark,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String?,
      name: json['name'] as String?,
      bloodType: json['bloodType'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      block: json['block'] as String?,
      email: json['email'] as String?,
      township: json['township'] as String?,
      gender: json['gender'] as String?,
      nrcNo: json['nrcNo'] as String?,
      remark: json['remark'] as String?,
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bloodType': bloodType,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'address': address,
      'block': block,
      'email': email,
      'township': township,
      'gender': gender,
      'nrcNo': nrcNo,
      'remark': remark,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Member copyWith({
    String? id,
    String? name,
    String? bloodType,
    String? dateOfBirth,
    String? phone,
    String? address,
    String? block,
    String? email,
    String? township,
    String? gender,
    String? nrcNo,
    String? remark,
    String? profileImage,
    String? createdAt,
    String? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      block: block ?? this.block,
      email: email ?? this.email,
      township: township ?? this.township,
      gender: gender ?? this.gender,
      nrcNo: nrcNo ?? this.nrcNo,
      remark: remark ?? this.remark,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
