import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Member {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? birthDate;
  String? bloodBankCard;
  String? bloodType;
  String? fatherName;
  DateTime? lastDate;
  String? memberCount;
  String? memberId;
  String? name;
  String? note;
  String? nrc;
  String? phone;
  String? address;
  DateTime? registerDate;
  String? totalCount;
  String? status;
  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _Donation {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? date;
  DateTime? donationDate;
  String? hospital;
  String? memberId;
  ObjectId? member;
  _Member? memberObj;
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _SpecialEvent {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? date;
  int? haemoglobin;
  int? hbsAg;
  int? hcvAb;
  int? mpIct;
  int? retroTest;
  int? vdrlTest;
  String? labName;
  int? total;
}

@RealmModel()
class _Donar {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  int? amount;
  String? date;
  String? name;
}

@RealmModel()
class _ExpenseRecord {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  int? amount;
  String? date;
  String? name;
}
