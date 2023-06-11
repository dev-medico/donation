import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final membersProvider = StateProvider<RealmResults<Member>>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Member>("TRUEPREDICATE SORT(_id ASC)");
});

final donationsProvider = StateProvider<RealmResults<Donation>>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Donation>("TRUEPREDICATE SORT(_id ASC)");
});

final totalMembersProvider = StateProvider<int>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm
      .query<Member>("TRUEPREDICATE SORT(_id ASC)")
      .length;
});

final totalDonationsProvider = StateProvider<int>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm
      .query<Donation>("TRUEPREDICATE SORT(_id ASC)")
      .length;
});
