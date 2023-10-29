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
  String? gender;
  String? profileUrl;
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
class _DonarRecord {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  int? amount;
  DateTime? date;
  String? name;
}

@RealmModel()
class _ExpensesRecord {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  int? amount;
  DateTime? date;
  String? name;
}

@RealmModel()
class _RequestGive {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  int? request;
  int? give;
  DateTime? date;
}

@RealmModel()
class _Noti {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? title;
  String? body;
  String? payload;
  DateTime? createdAt;
}

@RealmModel()
class _Post {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? text;
  late List<String> images;
  late List<_Reaction> reactions;
  late List<_Comment> comments;
  DateTime? createdAt;
  String? postedBy;
  String? posterProfileUrl;
}

@RealmModel()
class _Reaction {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? emoji;
  String? type;
  _Member? member;
  DateTime? createdAt;
}

@RealmModel()
class _Comment {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  String? text;
  _Member? member;
  late List<_Reaction> reactions;
  late List<_Comment> comments;
  DateTime? createdAt;
}
