import 'dart:developer';

import 'package:merchant/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:flutter/material.dart';

class RealmServices with ChangeNotifier {
  static const String queryAllName = "getAllSubscription";

  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  User? currentUser;
  App app;

  RealmServices(this.app) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(Configuration.flexibleSync(
          currentUser!, [Member.schema, Donation.schema]));
      if (realm.subscriptions.isEmpty) {
        updateSubscriptions();
      }
    }
  }

  Future<void> updateSubscriptions() async {
    log("Update Subscriptions Called");
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      mutableSubscriptions.add(realm.all<Member>(), name: queryAllName);
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

  void createDonation(
    String date,
    String hospital,
    String memberId,
    String patientAddress,
    String patientAge,
    String patientDisease,
    String patientName,
    String ownerId,
    Member mebmer,
  ) {
    final newDonation = Donation(
      ObjectId(),
      currentUser!.id,
      date: date,
      hospital: hospital,
      memberId: memberId,
      patientAddress: patientAddress,
      patientAge: patientAge,
      patientDisease: patientDisease,
      patientName: patientName,
      member: mebmer,
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
    String? patientDisease,
    String? patientName,
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
    });
    notifyListeners();
  }

  void deleteDonation(Donation donation) {
    realm.write(() => realm.delete(donation));
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
