import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

typedef SearchParams = ({String? search, String? bloodType});

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

final membersDataByPhoneProvider =
    StateProvider.family<Member?, String>((ref, phone) {
  var realmService = ref.watch(realmProvider);
  final stream = realmService!.realm.query<Member>(
      "phone CONTAINS[c] '$phone' AND TRUEPREDICATE SORT(memberId ASC)");

  return stream.isEmpty ? null : stream.first;
});

final searchMemberStreamProvider =
    StreamProvider.family<RealmResultsChanges<Member>, SearchParams>(
        (ref, searchParam) {
  var realmService = ref.watch(realmProvider);
  log("Search " + searchParam.search.toString());
  //get Datetime of four month before
  var fourMonthBefore = DateTime.now().subtract(Duration(days: 120));
  if (searchParam.search != "" &&
      searchParam.bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
    final stream = realmService!.realm.query<Member>(
        r"name CONTAINS[c] $1 AND bloodType ==$2 AND lastDate < $0 SORT(memberId ASC)",
        [
          fourMonthBefore,
          searchParam.search.toString().toLowerCase(),
          searchParam.bloodType.toString()
        ]).changes;

    return stream;
  } else if (searchParam.search != "") {
    final stream = realmService!.realm.query<Member>(
        r"name CONTAINS[c] $1 AND lastDate < $0 SORT(memberId ASC)", [
      fourMonthBefore,
      searchParam.search.toString().toLowerCase(),
    ]).changes;

    return stream;
  } else if (searchParam.bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
    final stream = realmService!.realm.query<Member>(
        r"bloodType ==$1 AND lastDate < $0 SORT(memberId ASC)",
        [fourMonthBefore, searchParam.bloodType.toString()]).changes;

    return stream;
  } else {
    final stream = realmService!.realm.query<Member>(
        r"lastDate < $0 TRUEPREDICATE SORT(memberId ASC)",
        [fourMonthBefore]).changes;

    return stream;
  }
});
