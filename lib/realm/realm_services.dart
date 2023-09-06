import 'dart:developer';

import 'package:donation/realm/app_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:flutter/material.dart';

final realmProvider = ChangeNotifierProvider<RealmServices?>((ref) {
  final appServices = ref.watch(appServiceProvider);
  return appServices.app.currentUser != null
      ? RealmServices(appServices.app)
      : null;
});

class RealmServices with ChangeNotifier {
  static const String queryAllName = "getAllSubscription";
  static const String queryAllDonationName = "getAllDonation";
  static const String queryAllSpecialEvent = "getAllSpecialEvent";
  static const String queryAllDonar = "getAllDonar";
  static const String queryAllExpenseRecord = "queryAllExpenseRecord";
  static const String queryAllPost = "queryAllPost";
  static const String queryAllNotification = "queryAllNotification";
  static const String queryAllReaction = "queryAllReaction";
  static const String queryAllComment = "queryAllComment";

  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  User? currentUser;
  App app;

  RealmServices(this.app) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(
        Configuration.flexibleSync(
          currentUser!,
          [
            Donation.schema,
            Member.schema,
            SpecialEvent.schema,
            DonarRecord.schema,
            ExpensesRecord.schema,
            Post.schema,
            Noti.schema,
            Reaction.schema,
            Comment.schema,
          ],
        ),
      );

      updateSubscriptions();
    }
  }

  Future<void> updateSubscriptions() async {
    log("Update Subscriptions Called");
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      mutableSubscriptions.add(realm.all<Member>(), name: queryAllName);
      mutableSubscriptions.add(realm.all<Donation>(),
          name: queryAllDonationName);
      mutableSubscriptions.add(realm.all<SpecialEvent>(),
          name: queryAllSpecialEvent);
      mutableSubscriptions.add(realm.all<DonarRecord>(), name: queryAllDonar);
      mutableSubscriptions.add(realm.all<ExpensesRecord>(),
          name: queryAllExpenseRecord);
      mutableSubscriptions.add(realm.all<Post>(), name: queryAllPost);
      mutableSubscriptions.add(realm.all<Noti>(), name: queryAllNotification);
      mutableSubscriptions.add(realm.all<Reaction>(), name: queryAllReaction);
      mutableSubscriptions.add(realm.all<Comment>(), name: queryAllComment);
    });
    await realm.subscriptions.waitForSynchronization();
  }

  Future<void> sessionSwitch() async {
    offlineModeOn = !offlineModeOn;
    if (offlineModeOn) {
      realm.syncSession.pause();
    } else {
      try {
        isWaiting = true;
        notifyListeners();
        realm.syncSession.resume();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    log("Switch Called");
    notifyListeners();
  }

  Future<void> switchSubscription() async {
    if (!offlineModeOn) {
      try {
        isWaiting = true;
        notifyListeners();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  void createMember(
      {String? name,
      String? birthDate,
      String? bloodBankCard,
      String? bloodType,
      String? fatherName,
      DateTime? lastDate,
      String? memberCount,
      String? memberId,
      String? note,
      String? nrc,
      String? phone,
      String? status,
      DateTime? registerDate,
      String? totalCount,
      String? address}) {
    final newMember = Member(
      ObjectId(),
      currentUser!.id,
      name: name,
      birthDate: birthDate,
      bloodBankCard: bloodBankCard,
      bloodType: bloodType,
      fatherName: fatherName,
      lastDate: lastDate,
      memberCount: memberCount,
      memberId: memberId,
      note: note,
      nrc: nrc,
      phone: phone,
      status: status,
      address: address,
      registerDate: registerDate,
      totalCount: totalCount,
    );
    realm.write<Member>(() => realm.add<Member>(newMember));
    notifyListeners();
  }

  Future<void> updateMember(Member member,
      {String? name,
      String? birthDate,
      String? bloodBankCard,
      String? bloodType,
      String? fatherName,
      DateTime? lastDate,
      String? memberCount,
      String? memberId,
      String? note,
      String? nrc,
      String? phone,
      String? status,
      DateTime? registerDate,
      String? totalCount,
      String? address}) async {
    realm.write(() {
      if (name != null) {
        member.name = name;
      }
      if (birthDate != null) {
        member.birthDate = birthDate;
      }
      if (bloodBankCard != null) {
        member.bloodBankCard = bloodBankCard;
      }
      if (bloodType != null) {
        member.bloodType = bloodType;
      }
      if (fatherName != null) {
        member.fatherName = fatherName;
      }

      if (lastDate != null) {
        member.lastDate = lastDate;
      }

      if (memberCount != null) {
        member.memberCount = memberCount;
      }
      if (memberId != null) {
        member.memberId = memberId;
      }
      if (note != null) {
        member.note = note;
      }
      if (nrc != null) {
        member.nrc = nrc;
      }
      if (phone != null) {
        member.phone = phone;
      }

      if (registerDate != null) {
        member.registerDate = registerDate;
      }

      if (totalCount != null) {
        member.totalCount = totalCount;
      }
      if (address != null) {
        member.address = address;
      }
      if (status != null) {
        member.status = status;
      }
    });
    notifyListeners();
  }

  void deleteMember(Member member) {
    realm.write(() => realm.delete(member));
    notifyListeners();
  }

  void deleteAllMember() {
    realm.write(() => realm.deleteAll());
    notifyListeners();
  }

  void createDonation({
    String? date,
    DateTime? donationDate,
    String? hospital,
    String? memberId,
    String? patientAddress,
    String? patientAge,
    Member? memberObj,
    String? patientDisease,
    String? patientName,
    String? ownerId,
    ObjectId? member,
  }) {
    final newDonation = Donation(
      ObjectId(),
      currentUser!.id,
      date: date,
      donationDate: donationDate,
      hospital: hospital,
      memberId: memberId,
      memberObj: memberObj,
      patientAddress: patientAddress,
      patientAge: patientAge,
      patientDisease: patientDisease,
      patientName: patientName,
      member: member,
    );
    realm.write<Donation>(() => realm.add<Donation>(newDonation));
    notifyListeners();
  }

  Future<void> updateDonation(
    Donation donation, {
    String? date,
    String? hospital,
    String? memberId,
    String? patientAddress,
    String? patientAge,
    DateTime? donationDate,
    String? patientDisease,
    String? patientName,
    ObjectId? member,
  }) async {
    realm.write(() {
      if (date != null) {
        donation.date = date;
      }
      if (hospital != null) {
        donation.hospital = hospital;
      }
      if (memberId != null) {
        donation.memberId = memberId;
      }
      if (patientAddress != null) {
        donation.patientAddress = patientAddress;
      }
      if (patientAge != null) {
        donation.patientAge = patientAge;
      }
      if (patientDisease != null) {
        donation.patientDisease = patientDisease;
      }
      if (patientName != null) {
        donation.patientName = patientName;
      }
      if (member != null) {
        donation.member = member;
      }
      if (donationDate != null) {
        donation.donationDate = donationDate;
      }
    });
    notifyListeners();
  }

  void deleteDonation(Donation donation) {
    realm.write(() => realm.delete(donation));
    notifyListeners();
  }

  void createSpecialEvent(SpecialEvent newSpecialEvent) {
    realm.write<SpecialEvent>(() => realm.add<SpecialEvent>(newSpecialEvent));
    notifyListeners();
  }

  void createDonar(DonarRecord newDonar) {
    realm.write<DonarRecord>(() => realm.add<DonarRecord>(newDonar));
    notifyListeners();
  }

  Future<void> updateDonar(
    DonarRecord donar, {
    int? amount,
    DateTime? date,
    String? name,
  }) async {
    realm.write(() {
      if (date != null) {
        donar.date = date;
      }
      if (amount != null) {
        donar.amount = amount;
      }
      if (name != null) {
        donar.name = name;
      }
    });
    notifyListeners();
  }

  void deleteDonar(DonarRecord donar) {
    realm.write(() => realm.delete(donar));
    notifyListeners();
  }

  void createExpenseRecord(newExpenseRecord) {
    realm.write<ExpensesRecord>(
        () => realm.add<ExpensesRecord>(newExpenseRecord));
    notifyListeners();
  }

  Future<void> updateExpenseRecord(
    ExpensesRecord expenseRecord, {
    int? amount,
    DateTime? date,
    String? name,
  }) async {
    realm.write(() {
      if (date != null) {
        expenseRecord.date = date;
      }
      if (amount != null) {
        expenseRecord.amount = amount;
      }
      if (name != null) {
        expenseRecord.name = name;
      }
    });
    notifyListeners();
  }

  void deleteExpenseRecord(ExpensesRecord expenseRecord) {
    realm.write(() => realm.delete(expenseRecord));
    notifyListeners();
  }

  void deleteAllDonation() {
    realm.write(() => realm.deleteAll());
    notifyListeners();
  }

  Future<void> close() async {
    if (currentUser != null) {
      await currentUser?.logOut();
      currentUser = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }
}
