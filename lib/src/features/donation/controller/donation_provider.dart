import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// typedef SearchParams = ({String? search, String? bloodType});

final donationStreamProvider =
    StreamProvider<RealmResultsChanges<Donation>>((ref) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm
      .query<Donation>("TRUEPREDICATE SORT(donationDate ASC)")
      .changes;

  return stream;
});
