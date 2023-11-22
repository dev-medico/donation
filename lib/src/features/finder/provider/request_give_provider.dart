import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final requestGiveProvider = StateProvider<RealmResults<RequestGive>>((ref) {
  var realmService = ref.watch(realmProvider);

  final stream =
      realmService!.realm.query<RequestGive>("TRUEPREDICATE SORT(date ASC)");

  return stream;
});

final requestGiveByYearProvider =
    StateProvider.family<List<RequestGive>, int>((ref, year) {
  var realmService = ref.watch(realmProvider);

  final stream =
      realmService!.realm.query<RequestGive>("TRUEPREDICATE SORT(date ASC)");

  return stream
      .where((element) => element.date!.toLocal().year == year)
      .toList();
});
