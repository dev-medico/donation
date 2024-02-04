import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

typedef SearchParams = ({String? search, String? bloodType});

typedef AgeRangeParams = ({int? start, int? end});

final memberStreamProvider =
    StreamProvider.family<RealmResultsChanges<Member>, SearchParams>(
        (ref, searchParam) {
  var realmService = ref.watch(realmProvider);
  log("Search " + searchParam.search.toString());
  if (searchParam.search != "" &&
      searchParam.bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
    final stream = realmService!.realm
        .query<Member>(
            "name CONTAINS[c] '${searchParam.search.toString().toLowerCase()}' AND bloodType =='${searchParam.bloodType.toString()}'")
        .changes;

    return stream;
  } else if (searchParam.search != "") {
    final stream = realmService!.realm
        .query<Member>(
            "name CONTAINS[c] '${searchParam.search.toString().toLowerCase()}'")
        .changes;

    return stream;
  } else if (searchParam.bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
    final stream = realmService!.realm
        .query<Member>("bloodType =='${searchParam.bloodType.toString()}'")
        .changes;

    return stream;
  } else {
    final stream = realmService!.realm
        .query<Member>("TRUEPREDICATE SORT(memberId ASC)")
        .changes;

    return stream;
  }
});

final membersDataProvider = StateProvider<RealmResults<Member>>((ref) {
  var realmService = ref.watch(realmProvider);
  final stream =
      realmService!.realm.query<Member>("TRUEPREDICATE SORT(memberId ASC)");

  return stream;
});

final averageAgeOfMemberProvider = StateProvider<int>((ref) {
  var realmService = ref.watch(realmProvider);
  final members =
      realmService!.realm.query<Member>("TRUEPREDICATE SORT(memberId ASC)");
  double totalAge = 0;
  members.forEach((element) {
    if (element.birthDate != null &&
        element.birthDate != "-" &&
        element.birthDate != "မွေးသက္ကရာဇ်") {
      if (element.birthDate!.contains("/")) {
        var birthDate = DateFormat('dd/MMM/yyyy').parse(element.birthDate!);

        var age = DateTime.now().difference(birthDate).inDays / 365;

        totalAge += age;
      } else {
        var birthDate = DateFormat('dd MMM yyyy').parse(element.birthDate!);

        var age = DateTime.now().difference(birthDate).inDays / 365;

        totalAge += age;
      }
    }
  });

  return (totalAge / members.length).round();
});

final memberCountByAgeRangeProvider =
    StateProvider.family<int, AgeRangeParams>((ref, ageRange) {
  //ageRange is 18 - 25
  var realmService = ref.watch(realmProvider);
  final members =
      realmService!.realm.query<Member>("TRUEPREDICATE SORT(memberId ASC)");
  int count = 0;
  members.forEach((element) {
    if (element.birthDate != null &&
        element.birthDate != "-" &&
        element.birthDate != "မွေးသက္ကရာဇ်") {
      if (element.birthDate!.contains("/")) {
        var birthDate = DateFormat('dd/MMM/yyyy').parse(element.birthDate!);

        var age = DateTime.now().difference(birthDate).inDays / 365;

        if (age >= ageRange.start! && age <= ageRange.end!) {
          count++;
        }
      } else {
        var birthDate = DateFormat('dd MMM yyyy').parse(element.birthDate!);

        var age = DateTime.now().difference(birthDate).inDays / 365;

        if (age >= ageRange.start! && age <= ageRange.end!) {
          count++;
        }
      }
    }
  });
  return count;
});
final membersDataByTotalCountProvider =
    StateProvider<RealmResults<Member>>((ref) {
  var realmService = ref.watch(realmProvider);
  final stream =
      realmService!.realm.query<Member>("TRUEPREDICATE SORT(totalCount DESC)");

  return stream;
});

final membersDataByPhoneProvider =
    StateProvider.family<Member?, String>((ref, phone) {
  var realmService = ref.watch(realmProvider);
  final stream = realmService!.realm.query<Member>(
      "phone CONTAINS[c] '$phone' AND TRUEPREDICATE SORT(memberId ASC)");

  return stream.isEmpty ? null : stream.first;
});

final loginMemberProvider = StateProvider<Member?>((ref) => null);

final searchMemberStreamProvider =
    StateProvider.family<RealmResults<Member>, SearchParams>(
        (ref, searchParam) {
  var realmService = ref.watch(realmProvider);
  log("Search " + searchParam.search.toString());
  log("Search " + searchParam.bloodType.toString());
  //get Datetime of four month before
  var fourMonthBefore = DateTime.now().subtract(Duration(days: 120));
  if (searchParam.search == "" &&
      searchParam.bloodType == "သွေးအုပ်စုဖြင့် ရှာဖွေမည်") {
    log("Call There");
    final stream = realmService!.realm.query<Member>(
        r"lastDate < $0 AND TRUEPREDICATE SORT(memberId ASC)",
        [fourMonthBefore]);

    return stream;
  } else if (searchParam.search != "" &&
      searchParam.bloodType != "သွေးအုပ်စုဖြင့် ရှာဖွေမည်") {
    final stream = realmService!.realm.query<Member>(
        r"name CONTAINS[c] $1 AND bloodType ==$2 AND lastDate < $0 SORT(memberId ASC)",
        [
          fourMonthBefore,
          searchParam.search.toString().toLowerCase(),
          searchParam.bloodType.toString()
        ]);

    return stream;
  } else if (searchParam.search != "") {
    final stream = realmService!.realm.query<Member>(
        r"name CONTAINS[c] $1 AND lastDate < $0 SORT(memberId ASC)", [
      fourMonthBefore,
      searchParam.search.toString().toLowerCase(),
    ]);

    return stream;
  } else if (searchParam.bloodType != "သွေးအုပ်စုဖြင့် ရှာဖွေမည်") {
    final stream = realmService!.realm.query<Member>(
        r"bloodType ==$1 AND lastDate < $0 SORT(memberId ASC)",
        [fourMonthBefore, searchParam.bloodType.toString()]);

    return stream;
  } else {
    log("Call Here");
    final stream = realmService!.realm.query<Member>(
        r"lastDate < $0 AND TRUEPREDICATE SORT(memberId ASC)",
        [fourMonthBefore]);

    return stream;
  }
});
