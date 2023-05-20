import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

    log("realm Data" +
        realmService.realm
            .query<Member>("TRUEPREDICATE SORT(_id ASC)")
            .length
            .toString());

    return stream;
  }
});
