import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final donarsDataProvider = StateProvider<RealmResults<DonarRecord>>((ref) {
  var realmService = ref.watch(realmProvider);
  final stream =
      realmService!.realm.query<DonarRecord>("TRUEPREDICATE SORT(_id ASC)");

  return stream;
});

final expensesDataProvider = StateProvider<RealmResults<ExpensesRecord>>((ref) {
  var realmService = ref.watch(realmProvider);
  final stream =
      realmService!.realm.query<ExpensesRecord>("TRUEPREDICATE SORT(_id ASC)");

  return stream;
});