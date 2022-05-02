import 'package:objectbox/objectbox.dart';

@Entity()
class MemberLocal {
  @Id(assignable: true)
  int? id;
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
}
