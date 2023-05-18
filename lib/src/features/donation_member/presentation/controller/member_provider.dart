import 'dart:convert';
import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/data/response/xata_member_list_response.dart';
import 'package:donation/realm/realm_provider.dart';
import 'package:donation/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_provider.g.dart';

final memberStreamProvider = StreamProvider.autoDispose
    .family<RealmResultsChanges<Member>, String>((ref, search) {
  var realmService = ref.watch(realmServiceProvider);
  log("Search " + search);
  // final stream = search != ""
  //     ? realmService!.realm
  //         .query<Member>("name CONTAINS[c] '${search.toLowerCase()}'")
  //         .changes
  //     : realmService!.realm
  //         .query<Member>("TRUEPREDICATE SORT(memberId ASC)")
  //         .changes;
  final stream = realmService!.realm
      .query<Member>("TRUEPREDICATE SORT(memberId ASC)")
      .changes;
  // stream.length.then((value) => log("Stream " + value.toString()));

  return stream;
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
