import 'dart:convert';
import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/data/response/xata_member_list_response.dart';
import 'package:donation/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_provider.g.dart';

typedef SearchParams = ({String? search, String? bloodType});

final memberStreamProvider = StreamProvider.autoDispose
    .family<RealmResultsChanges<Member>, SearchParams>((ref, searchParam) {
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

// create a provider that store list of objects that pass to it
class Members extends StateNotifier<List<MemberData>> {
  Members() : super([]);

  void addMember(MemberData member) {
    state = [...state, member];
  }
}

final membersProvider = StateNotifierProvider<Members, List<MemberData>>((ref) {
  return Members();
});

@riverpod
Future<List<MemberData>> memberList(MemberListRef ref) async {
  List<MemberData> data = await callAPI("", [], ref);
  return data;
}

List<MemberData> callAPI(
    String after, List<MemberData> oldData, MemberListRef ref) {
  XataRepository().getMemberList(after).then((response) {
    log(response.body.toString());

    oldData.addAll(
        XataMemberListResponse.fromJson(jsonDecode(response.body)).records!);

    if (XataMemberListResponse.fromJson(jsonDecode(response.body))
        .meta!
        .page!
        .more!) {
      callAPI(
          XataMemberListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .cursor!,
          oldData,
          ref);
    } else {
      return oldData;
    }
  });
  return oldData;
}
