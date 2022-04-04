class Member {
  String? birth_date;
  String? blood_bank_card;
  String? blood_type;
  String? member_id;
  String? father_name;
  String? name;

  Member(String birth_date, String blood_bank_card, String blood_type,
      String member_id, String father_name, String name) {
    birth_date = birth_date;
    blood_bank_card = blood_bank_card;
    blood_type = blood_type;
    member_id = member_id;
    father_name = father_name;
    name = name;
  }

  static Member fromMap(Map<String, dynamic> map) {
    return Member(map['birth_date'], map['blood_bank_card'], map["blood_type"],
        map["member_id"], map["father_name"], map["name"]);
  }
}
