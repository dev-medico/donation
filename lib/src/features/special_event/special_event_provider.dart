import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final specialEventsDataProvider =
    StateProvider<RealmResults<SpecialEvent>>((ref) {
  var realmService = ref.watch(realmProvider);
  final stream = realmService!.realm
      .query<SpecialEvent>("TRUEPREDICATE SORT(id ASC)");

  return stream;
});
