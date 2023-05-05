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
  String? homeNo;
  String? lastDate;
  String? lastDateDetail;
  String? memberCount;
  String? memberId;
  String? name;
  String? note;
  String? nrc;
  String? phone;
  String? quarter;
  String? region;
  String? registerDate;
  String? street;
  String? totalCount;
  String? town;
  @MapTo('owner_id')
  late String ownerId;
}

@RealmModel()
class _Donation {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? date;
  String? hospital;
  String? memberId;
  _Member? member;
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  @MapTo('owner_id')
  late String ownerId;
}
