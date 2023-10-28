import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation/controller/donation_list_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// typedef SearchParams = ({String? search, String? bloodType});

final donationStreamProvider =
    StreamProvider<RealmResultsChanges<Donation>>((ref) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm
      .query<Donation>("TRUEPREDICATE SORT(donationDate DESC)")
      .changes;

  return stream;
});

final donationProvider = StateProvider<RealmResults<Donation>>((ref) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm
      .query<Donation>("TRUEPREDICATE SORT(donationDate DESC)");

  return stream;
});

final donationByMonthYearStreamProvider =
    StreamProvider.family<RealmResultsChanges<Donation>, DonationFilterModel>(
        (ref, filter) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<Donation>(
      r"donationDate > $0 AND donationDate <= $1 AND TRUEPREDICATE SORT(donationDate ASC)",
      [
        DateTime(filter.year!, filter.month!, 1),
        DateTime(filter.year!, filter.month! + 1, 1),
      ]).changes;

  return stream;
});

final donationByYearProvider =
    StateProvider.family<RealmResults<Donation>, int>((ref, year) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<Donation>(
      r"donationDate > $0 AND donationDate <= $1 AND TRUEPREDICATE SORT(donationDate ASC)",
      [
        DateTime(year, 1, 1),
        DateTime(year + 1, 1, 1),
      ]);

  return stream;
});
