import 'dart:convert';
import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/data/response/xata_member_list_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_provider.g.dart';

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

    // if (oldData.isNotEmpty) {
    //   oldData.forEach((element) {
    //     ref.read(membersProvider.notifier).addMember(element);
    //     log("Member Length -" +
    //         ref.read(membersProvider.notifier).state.length.toString());
    //   });
    // }

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
