// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Member extends _Member with RealmEntity, RealmObjectBase, RealmObject {
  Member(
    ObjectId id,
    String ownerId, {
    String? birthDate,
    String? bloodBankCard,
    String? bloodType,
    String? fatherName,
    String? homeNo,
    String? lastDate,
    String? lastDateDetail,
    String? memberCount,
    String? memberId,
    String? name,
    String? note,
    String? nrc,
    String? phone,
    String? quarter,
    String? region,
    String? registerDate,
    String? street,
    String? totalCount,
    String? town,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'birthDate', birthDate);
    RealmObjectBase.set(this, 'bloodBankCard', bloodBankCard);
    RealmObjectBase.set(this, 'bloodType', bloodType);
    RealmObjectBase.set(this, 'fatherName', fatherName);
    RealmObjectBase.set(this, 'homeNo', homeNo);
    RealmObjectBase.set(this, 'lastDate', lastDate);
    RealmObjectBase.set(this, 'lastDateDetail', lastDateDetail);
    RealmObjectBase.set(this, 'memberCount', memberCount);
    RealmObjectBase.set(this, 'memberId', memberId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'nrc', nrc);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'quarter', quarter);
    RealmObjectBase.set(this, 'region', region);
    RealmObjectBase.set(this, 'registerDate', registerDate);
    RealmObjectBase.set(this, 'street', street);
    RealmObjectBase.set(this, 'totalCount', totalCount);
    RealmObjectBase.set(this, 'town', town);
    RealmObjectBase.set(this, 'owner_id', ownerId);
  }

  Member._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get birthDate =>
      RealmObjectBase.get<String>(this, 'birthDate') as String?;
  @override
  set birthDate(String? value) => RealmObjectBase.set(this, 'birthDate', value);

  @override
  String? get bloodBankCard =>
      RealmObjectBase.get<String>(this, 'bloodBankCard') as String?;
  @override
  set bloodBankCard(String? value) =>
      RealmObjectBase.set(this, 'bloodBankCard', value);

  @override
  String? get bloodType =>
      RealmObjectBase.get<String>(this, 'bloodType') as String?;
  @override
  set bloodType(String? value) => RealmObjectBase.set(this, 'bloodType', value);

  @override
  String? get fatherName =>
      RealmObjectBase.get<String>(this, 'fatherName') as String?;
  @override
  set fatherName(String? value) =>
      RealmObjectBase.set(this, 'fatherName', value);

  @override
  String? get homeNo => RealmObjectBase.get<String>(this, 'homeNo') as String?;
  @override
  set homeNo(String? value) => RealmObjectBase.set(this, 'homeNo', value);

  @override
  String? get lastDate =>
      RealmObjectBase.get<String>(this, 'lastDate') as String?;
  @override
  set lastDate(String? value) => RealmObjectBase.set(this, 'lastDate', value);

  @override
  String? get lastDateDetail =>
      RealmObjectBase.get<String>(this, 'lastDateDetail') as String?;
  @override
  set lastDateDetail(String? value) =>
      RealmObjectBase.set(this, 'lastDateDetail', value);

  @override
  String? get memberCount =>
      RealmObjectBase.get<String>(this, 'memberCount') as String?;
  @override
  set memberCount(String? value) =>
      RealmObjectBase.set(this, 'memberCount', value);

  @override
  String? get memberId =>
      RealmObjectBase.get<String>(this, 'memberId') as String?;
  @override
  set memberId(String? value) => RealmObjectBase.set(this, 'memberId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String? get nrc => RealmObjectBase.get<String>(this, 'nrc') as String?;
  @override
  set nrc(String? value) => RealmObjectBase.set(this, 'nrc', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get quarter =>
      RealmObjectBase.get<String>(this, 'quarter') as String?;
  @override
  set quarter(String? value) => RealmObjectBase.set(this, 'quarter', value);

  @override
  String? get region => RealmObjectBase.get<String>(this, 'region') as String?;
  @override
  set region(String? value) => RealmObjectBase.set(this, 'region', value);

  @override
  String? get registerDate =>
      RealmObjectBase.get<String>(this, 'registerDate') as String?;
  @override
  set registerDate(String? value) =>
      RealmObjectBase.set(this, 'registerDate', value);

  @override
  String? get street => RealmObjectBase.get<String>(this, 'street') as String?;
  @override
  set street(String? value) => RealmObjectBase.set(this, 'street', value);

  @override
  String? get totalCount =>
      RealmObjectBase.get<String>(this, 'totalCount') as String?;
  @override
  set totalCount(String? value) =>
      RealmObjectBase.set(this, 'totalCount', value);

  @override
  String? get town => RealmObjectBase.get<String>(this, 'town') as String?;
  @override
  set town(String? value) => RealmObjectBase.set(this, 'town', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'owner_id') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'owner_id', value);

  @override
  Stream<RealmObjectChanges<Member>> get changes =>
      RealmObjectBase.getChanges<Member>(this);

  @override
  Member freeze() => RealmObjectBase.freezeObject<Member>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Member._);
    return const SchemaObject(ObjectType.realmObject, Member, 'Member', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('birthDate', RealmPropertyType.string, optional: true),
      SchemaProperty('bloodBankCard', RealmPropertyType.string, optional: true),
      SchemaProperty('bloodType', RealmPropertyType.string, optional: true),
      SchemaProperty('fatherName', RealmPropertyType.string, optional: true),
      SchemaProperty('homeNo', RealmPropertyType.string, optional: true),
      SchemaProperty('lastDate', RealmPropertyType.string, optional: true),
      SchemaProperty('lastDateDetail', RealmPropertyType.string,
          optional: true),
      SchemaProperty('memberCount', RealmPropertyType.string, optional: true),
      SchemaProperty('memberId', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('nrc', RealmPropertyType.string, optional: true),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('quarter', RealmPropertyType.string, optional: true),
      SchemaProperty('region', RealmPropertyType.string, optional: true),
      SchemaProperty('registerDate', RealmPropertyType.string, optional: true),
      SchemaProperty('street', RealmPropertyType.string, optional: true),
      SchemaProperty('totalCount', RealmPropertyType.string, optional: true),
      SchemaProperty('town', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}

class Donation extends _Donation
    with RealmEntity, RealmObjectBase, RealmObject {
  Donation(
    ObjectId id,
    String ownerId, {
    String? date,
    String? hospital,
    String? memberId,
    Member? member,
    String? patientAddress,
    String? patientAge,
    String? patientDisease,
    String? patientName,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'hospital', hospital);
    RealmObjectBase.set(this, 'memberId', memberId);
    RealmObjectBase.set(this, 'member', member);
    RealmObjectBase.set(this, 'patientAddress', patientAddress);
    RealmObjectBase.set(this, 'patientAge', patientAge);
    RealmObjectBase.set(this, 'patientDisease', patientDisease);
    RealmObjectBase.set(this, 'patientName', patientName);
    RealmObjectBase.set(this, 'owner_id', ownerId);
  }

  Donation._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get date => RealmObjectBase.get<String>(this, 'date') as String?;
  @override
  set date(String? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get hospital =>
      RealmObjectBase.get<String>(this, 'hospital') as String?;
  @override
  set hospital(String? value) => RealmObjectBase.set(this, 'hospital', value);

  @override
  String? get memberId =>
      RealmObjectBase.get<String>(this, 'memberId') as String?;
  @override
  set memberId(String? value) => RealmObjectBase.set(this, 'memberId', value);

  @override
  Member? get member => RealmObjectBase.get<Member>(this, 'member') as Member?;
  @override
  set member(covariant Member? value) =>
      RealmObjectBase.set(this, 'member', value);

  @override
  String? get patientAddress =>
      RealmObjectBase.get<String>(this, 'patientAddress') as String?;
  @override
  set patientAddress(String? value) =>
      RealmObjectBase.set(this, 'patientAddress', value);

  @override
  String? get patientAge =>
      RealmObjectBase.get<String>(this, 'patientAge') as String?;
  @override
  set patientAge(String? value) =>
      RealmObjectBase.set(this, 'patientAge', value);

  @override
  String? get patientDisease =>
      RealmObjectBase.get<String>(this, 'patientDisease') as String?;
  @override
  set patientDisease(String? value) =>
      RealmObjectBase.set(this, 'patientDisease', value);

  @override
  String? get patientName =>
      RealmObjectBase.get<String>(this, 'patientName') as String?;
  @override
  set patientName(String? value) =>
      RealmObjectBase.set(this, 'patientName', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'owner_id') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'owner_id', value);

  @override
  Stream<RealmObjectChanges<Donation>> get changes =>
      RealmObjectBase.getChanges<Donation>(this);

  @override
  Donation freeze() => RealmObjectBase.freezeObject<Donation>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Donation._);
    return const SchemaObject(ObjectType.realmObject, Donation, 'Donation', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('date', RealmPropertyType.string, optional: true),
      SchemaProperty('hospital', RealmPropertyType.string, optional: true),
      SchemaProperty('memberId', RealmPropertyType.string, optional: true),
      SchemaProperty('member', RealmPropertyType.object,
          optional: true, linkTarget: 'Member'),
      SchemaProperty('patientAddress', RealmPropertyType.string,
          optional: true),
      SchemaProperty('patientAge', RealmPropertyType.string, optional: true),
      SchemaProperty('patientDisease', RealmPropertyType.string,
          optional: true),
      SchemaProperty('patientName', RealmPropertyType.string, optional: true),
      SchemaProperty('ownerId', RealmPropertyType.string, mapTo: 'owner_id'),
    ]);
  }
}
