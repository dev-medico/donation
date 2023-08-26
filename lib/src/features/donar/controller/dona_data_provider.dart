import 'dart:developer';

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

typedef ClosingParams = ({int? month, int? year});

final closingBalanceDataProvider =
    StateProvider.family<int, ClosingParams>((ref, param) {
  var donars = ref.watch(donarsDataProvider);
  var expenses = ref.watch(expensesDataProvider);

  int totalDonation = 0;
  int totalExpenses = 0;
  int closingBalance = 0;
  log("Year - " + param.month.toString() + " - " + param.year.toString());
  donars
      .where((element) => element.date!.isBefore(DateTime(
            param.year!,
            param.month!,
            31

          )))
      .forEach((element) {
    totalDonation += element.amount!;
  });

  expenses
      .where((element2) => element2.date!.isBefore(DateTime(
            param.year!,
            param.month!,
            31
          )))
      .forEach((data) {
    totalExpenses += data.amount!;
  });

  closingBalance = totalDonation - totalExpenses;

  log("Total Donation - " +
      totalDonation.toString() +
      " - " +
      totalExpenses.toString());

  log("Closing Balance  - " + closingBalance.toString());
  log("-------------------------------------------");

  return closingBalance;
});
