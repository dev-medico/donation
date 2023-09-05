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
    DateTime? lastDate,
    String? memberCount,
    String? memberId,
    String? name,
    String? note,
    String? nrc,
    String? phone,
    String? address,
    String? profileUrl,
    DateTime? registerDate,
    String? totalCount,
    String? status,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'birthDate', birthDate);
    RealmObjectBase.set(this, 'bloodBankCard', bloodBankCard);
    RealmObjectBase.set(this, 'bloodType', bloodType);
    RealmObjectBase.set(this, 'fatherName', fatherName);
    RealmObjectBase.set(this, 'lastDate', lastDate);
    RealmObjectBase.set(this, 'memberCount', memberCount);
    RealmObjectBase.set(this, 'memberId', memberId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'nrc', nrc);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'profileUrl', profileUrl);
    RealmObjectBase.set(this, 'registerDate', registerDate);
    RealmObjectBase.set(this, 'totalCount', totalCount);
    RealmObjectBase.set(this, 'status', status);
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
  DateTime? get lastDate =>
      RealmObjectBase.get<DateTime>(this, 'lastDate') as DateTime?;
  @override
  set lastDate(DateTime? value) => RealmObjectBase.set(this, 'lastDate', value);

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
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  String? get profileUrl =>
      RealmObjectBase.get<String>(this, 'profileUrl') as String?;
  @override
  set profileUrl(String? value) =>
      RealmObjectBase.set(this, 'profileUrl', value);

  @override
  DateTime? get registerDate =>
      RealmObjectBase.get<DateTime>(this, 'registerDate') as DateTime?;
  @override
  set registerDate(DateTime? value) =>
      RealmObjectBase.set(this, 'registerDate', value);

  @override
  String? get totalCount =>
      RealmObjectBase.get<String>(this, 'totalCount') as String?;
  @override
  set totalCount(String? value) =>
      RealmObjectBase.set(this, 'totalCount', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

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
      SchemaProperty('lastDate', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('memberCount', RealmPropertyType.string, optional: true),
      SchemaProperty('memberId', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('nrc', RealmPropertyType.string, optional: true),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('profileUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('registerDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('totalCount', RealmPropertyType.string, optional: true),
      SchemaProperty('status', RealmPropertyType.string, optional: true),
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
    DateTime? donationDate,
    String? hospital,
    String? memberId,
    ObjectId? member,
    Member? memberObj,
    String? patientAddress,
    String? patientAge,
    String? patientDisease,
    String? patientName,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'donationDate', donationDate);
    RealmObjectBase.set(this, 'hospital', hospital);
    RealmObjectBase.set(this, 'memberId', memberId);
    RealmObjectBase.set(this, 'member', member);
    RealmObjectBase.set(this, 'memberObj', memberObj);
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
  DateTime? get donationDate =>
      RealmObjectBase.get<DateTime>(this, 'donationDate') as DateTime?;
  @override
  set donationDate(DateTime? value) =>
      RealmObjectBase.set(this, 'donationDate', value);

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
  ObjectId? get member =>
      RealmObjectBase.get<ObjectId>(this, 'member') as ObjectId?;
  @override
  set member(ObjectId? value) => RealmObjectBase.set(this, 'member', value);

  @override
  Member? get memberObj =>
      RealmObjectBase.get<Member>(this, 'memberObj') as Member?;
  @override
  set memberObj(covariant Member? value) =>
      RealmObjectBase.set(this, 'memberObj', value);

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
      SchemaProperty('donationDate', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('hospital', RealmPropertyType.string, optional: true),
      SchemaProperty('memberId', RealmPropertyType.string, optional: true),
      SchemaProperty('member', RealmPropertyType.objectid, optional: true),
      SchemaProperty('memberObj', RealmPropertyType.object,
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

class SpecialEvent extends _SpecialEvent
    with RealmEntity, RealmObjectBase, RealmObject {
  SpecialEvent(
    ObjectId id, {
    String? date,
    int? haemoglobin,
    int? hbsAg,
    int? hcvAb,
    int? mpIct,
    int? retroTest,
    int? vdrlTest,
    String? labName,
    int? total,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'haemoglobin', haemoglobin);
    RealmObjectBase.set(this, 'hbsAg', hbsAg);
    RealmObjectBase.set(this, 'hcvAb', hcvAb);
    RealmObjectBase.set(this, 'mpIct', mpIct);
    RealmObjectBase.set(this, 'retroTest', retroTest);
    RealmObjectBase.set(this, 'vdrlTest', vdrlTest);
    RealmObjectBase.set(this, 'labName', labName);
    RealmObjectBase.set(this, 'total', total);
  }

  SpecialEvent._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get date => RealmObjectBase.get<String>(this, 'date') as String?;
  @override
  set date(String? value) => RealmObjectBase.set(this, 'date', value);

  @override
  int? get haemoglobin => RealmObjectBase.get<int>(this, 'haemoglobin') as int?;
  @override
  set haemoglobin(int? value) =>
      RealmObjectBase.set(this, 'haemoglobin', value);

  @override
  int? get hbsAg => RealmObjectBase.get<int>(this, 'hbsAg') as int?;
  @override
  set hbsAg(int? value) => RealmObjectBase.set(this, 'hbsAg', value);

  @override
  int? get hcvAb => RealmObjectBase.get<int>(this, 'hcvAb') as int?;
  @override
  set hcvAb(int? value) => RealmObjectBase.set(this, 'hcvAb', value);

  @override
  int? get mpIct => RealmObjectBase.get<int>(this, 'mpIct') as int?;
  @override
  set mpIct(int? value) => RealmObjectBase.set(this, 'mpIct', value);

  @override
  int? get retroTest => RealmObjectBase.get<int>(this, 'retroTest') as int?;
  @override
  set retroTest(int? value) => RealmObjectBase.set(this, 'retroTest', value);

  @override
  int? get vdrlTest => RealmObjectBase.get<int>(this, 'vdrlTest') as int?;
  @override
  set vdrlTest(int? value) => RealmObjectBase.set(this, 'vdrlTest', value);

  @override
  String? get labName =>
      RealmObjectBase.get<String>(this, 'labName') as String?;
  @override
  set labName(String? value) => RealmObjectBase.set(this, 'labName', value);

  @override
  int? get total => RealmObjectBase.get<int>(this, 'total') as int?;
  @override
  set total(int? value) => RealmObjectBase.set(this, 'total', value);

  @override
  Stream<RealmObjectChanges<SpecialEvent>> get changes =>
      RealmObjectBase.getChanges<SpecialEvent>(this);

  @override
  SpecialEvent freeze() => RealmObjectBase.freezeObject<SpecialEvent>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(SpecialEvent._);
    return const SchemaObject(
        ObjectType.realmObject, SpecialEvent, 'SpecialEvent', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('date', RealmPropertyType.string, optional: true),
      SchemaProperty('haemoglobin', RealmPropertyType.int, optional: true),
      SchemaProperty('hbsAg', RealmPropertyType.int, optional: true),
      SchemaProperty('hcvAb', RealmPropertyType.int, optional: true),
      SchemaProperty('mpIct', RealmPropertyType.int, optional: true),
      SchemaProperty('retroTest', RealmPropertyType.int, optional: true),
      SchemaProperty('vdrlTest', RealmPropertyType.int, optional: true),
      SchemaProperty('labName', RealmPropertyType.string, optional: true),
      SchemaProperty('total', RealmPropertyType.int, optional: true),
    ]);
  }
}

class DonarRecord extends _DonarRecord
    with RealmEntity, RealmObjectBase, RealmObject {
  DonarRecord(
    ObjectId id, {
    int? amount,
    DateTime? date,
    String? name,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'name', name);
  }

  DonarRecord._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  int? get amount => RealmObjectBase.get<int>(this, 'amount') as int?;
  @override
  set amount(int? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  DateTime? get date =>
      RealmObjectBase.get<DateTime>(this, 'date') as DateTime?;
  @override
  set date(DateTime? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<DonarRecord>> get changes =>
      RealmObjectBase.getChanges<DonarRecord>(this);

  @override
  DonarRecord freeze() => RealmObjectBase.freezeObject<DonarRecord>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(DonarRecord._);
    return const SchemaObject(
        ObjectType.realmObject, DonarRecord, 'DonarRecord', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('amount', RealmPropertyType.int, optional: true),
      SchemaProperty('date', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
    ]);
  }
}

class ExpensesRecord extends _ExpensesRecord
    with RealmEntity, RealmObjectBase, RealmObject {
  ExpensesRecord(
    ObjectId id, {
    int? amount,
    DateTime? date,
    String? name,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'name', name);
  }

  ExpensesRecord._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  int? get amount => RealmObjectBase.get<int>(this, 'amount') as int?;
  @override
  set amount(int? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  DateTime? get date =>
      RealmObjectBase.get<DateTime>(this, 'date') as DateTime?;
  @override
  set date(DateTime? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<ExpensesRecord>> get changes =>
      RealmObjectBase.getChanges<ExpensesRecord>(this);

  @override
  ExpensesRecord freeze() => RealmObjectBase.freezeObject<ExpensesRecord>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ExpensesRecord._);
    return const SchemaObject(
        ObjectType.realmObject, ExpensesRecord, 'ExpensesRecord', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('amount', RealmPropertyType.int, optional: true),
      SchemaProperty('date', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Notification extends _Notification
    with RealmEntity, RealmObjectBase, RealmObject {
  Notification(
    ObjectId id, {
    String? title,
    String? body,
    String? payload,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'body', body);
    RealmObjectBase.set(this, 'payload', payload);
  }

  Notification._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get title => RealmObjectBase.get<String>(this, 'title') as String?;
  @override
  set title(String? value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get body => RealmObjectBase.get<String>(this, 'body') as String?;
  @override
  set body(String? value) => RealmObjectBase.set(this, 'body', value);

  @override
  String? get payload =>
      RealmObjectBase.get<String>(this, 'payload') as String?;
  @override
  set payload(String? value) => RealmObjectBase.set(this, 'payload', value);

  @override
  Stream<RealmObjectChanges<Notification>> get changes =>
      RealmObjectBase.getChanges<Notification>(this);

  @override
  Notification freeze() => RealmObjectBase.freezeObject<Notification>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Notification._);
    return const SchemaObject(
        ObjectType.realmObject, Notification, 'Notification', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string, optional: true),
      SchemaProperty('body', RealmPropertyType.string, optional: true),
      SchemaProperty('payload', RealmPropertyType.string, optional: true),
    ]);
  }
}

class Post extends _Post with RealmEntity, RealmObjectBase, RealmObject {
  Post(
    ObjectId id, {
    String? text,
    Iterable<String> images = const [],
    Iterable<Reaction> reactions = const [],
    Iterable<Comment> comments = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'text', text);
    RealmObjectBase.set<RealmList<String>>(
        this, 'images', RealmList<String>(images));
    RealmObjectBase.set<RealmList<Reaction>>(
        this, 'reactions', RealmList<Reaction>(reactions));
    RealmObjectBase.set<RealmList<Comment>>(
        this, 'comments', RealmList<Comment>(comments));
  }

  Post._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get text => RealmObjectBase.get<String>(this, 'text') as String?;
  @override
  set text(String? value) => RealmObjectBase.set(this, 'text', value);

  @override
  RealmList<String> get images =>
      RealmObjectBase.get<String>(this, 'images') as RealmList<String>;
  @override
  set images(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Reaction> get reactions =>
      RealmObjectBase.get<Reaction>(this, 'reactions') as RealmList<Reaction>;
  @override
  set reactions(covariant RealmList<Reaction> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Comment> get comments =>
      RealmObjectBase.get<Comment>(this, 'comments') as RealmList<Comment>;
  @override
  set comments(covariant RealmList<Comment> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Post>> get changes =>
      RealmObjectBase.getChanges<Post>(this);

  @override
  Post freeze() => RealmObjectBase.freezeObject<Post>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Post._);
    return const SchemaObject(ObjectType.realmObject, Post, 'Post', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('text', RealmPropertyType.string, optional: true),
      SchemaProperty('images', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('reactions', RealmPropertyType.object,
          linkTarget: 'Reaction', collectionType: RealmCollectionType.list),
      SchemaProperty('comments', RealmPropertyType.object,
          linkTarget: 'Comment', collectionType: RealmCollectionType.list),
    ]);
  }
}

class Reaction extends _Reaction
    with RealmEntity, RealmObjectBase, RealmObject {
  Reaction(
    ObjectId id, {
    String? emoji,
    String? type,
    Member? member,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'emoji', emoji);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'member', member);
  }

  Reaction._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get emoji => RealmObjectBase.get<String>(this, 'emoji') as String?;
  @override
  set emoji(String? value) => RealmObjectBase.set(this, 'emoji', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  Member? get member => RealmObjectBase.get<Member>(this, 'member') as Member?;
  @override
  set member(covariant Member? value) =>
      RealmObjectBase.set(this, 'member', value);

  @override
  Stream<RealmObjectChanges<Reaction>> get changes =>
      RealmObjectBase.getChanges<Reaction>(this);

  @override
  Reaction freeze() => RealmObjectBase.freezeObject<Reaction>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Reaction._);
    return const SchemaObject(ObjectType.realmObject, Reaction, 'Reaction', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('emoji', RealmPropertyType.string, optional: true),
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('member', RealmPropertyType.object,
          optional: true, linkTarget: 'Member'),
    ]);
  }
}

class Comment extends _Comment with RealmEntity, RealmObjectBase, RealmObject {
  Comment(
    ObjectId id, {
    String? text,
    Member? member,
    Iterable<Reaction> reactions = const [],
    Iterable<Comment> comments = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'text', text);
    RealmObjectBase.set(this, 'member', member);
    RealmObjectBase.set<RealmList<Reaction>>(
        this, 'reactions', RealmList<Reaction>(reactions));
    RealmObjectBase.set<RealmList<Comment>>(
        this, 'comments', RealmList<Comment>(comments));
  }

  Comment._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get text => RealmObjectBase.get<String>(this, 'text') as String?;
  @override
  set text(String? value) => RealmObjectBase.set(this, 'text', value);

  @override
  Member? get member => RealmObjectBase.get<Member>(this, 'member') as Member?;
  @override
  set member(covariant Member? value) =>
      RealmObjectBase.set(this, 'member', value);

  @override
  RealmList<Reaction> get reactions =>
      RealmObjectBase.get<Reaction>(this, 'reactions') as RealmList<Reaction>;
  @override
  set reactions(covariant RealmList<Reaction> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Comment> get comments =>
      RealmObjectBase.get<Comment>(this, 'comments') as RealmList<Comment>;
  @override
  set comments(covariant RealmList<Comment> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Comment>> get changes =>
      RealmObjectBase.getChanges<Comment>(this);

  @override
  Comment freeze() => RealmObjectBase.freezeObject<Comment>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Comment._);
    return const SchemaObject(ObjectType.realmObject, Comment, 'Comment', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('text', RealmPropertyType.string, optional: true),
      SchemaProperty('member', RealmPropertyType.object,
          optional: true, linkTarget: 'Member'),
      SchemaProperty('reactions', RealmPropertyType.object,
          linkTarget: 'Reaction', collectionType: RealmCollectionType.list),
      SchemaProperty('comments', RealmPropertyType.object,
          linkTarget: 'Comment', collectionType: RealmCollectionType.list),
    ]);
  }
}
