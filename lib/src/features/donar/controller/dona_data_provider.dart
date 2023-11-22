import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donar/controller/donar_list_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final donarByMonthYearStreamProvider =
    StreamProvider.family<RealmResultsChanges<DonarRecord>, DonarFilterModel>(
        (ref, filter) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<DonarRecord>(
      r"date >= $0 AND date < $1 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year!, filter.month!, 1),
    DateTime(filter.year!, filter.month! + 1, 1),
  ]).changes;

  return stream;
});

final donarByYearProvider =
    StateProvider.family<List<DonarRecord>, int>((ref, year) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<DonarRecord>(
    "TRUEPREDICATE SORT(date ASC)",
  );

  List<DonarRecord> donars = [];
  stream.forEach((element) {
    if (element.date!.toLocal().year == year) donars.add(element);
  });

  return donars;
});

final expenseByMonthYearStreamProvider = StreamProvider.family<
    RealmResultsChanges<ExpensesRecord>, DonarFilterModel>((ref, filter) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<ExpensesRecord>(
      r"date >= $0 AND date < $1 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year!, filter.month!, 1),
    DateTime(filter.year!, filter.month! + 1, 1),
  ]).changes;

  return stream;
});

final expenseByYearProvider =
    StateProvider.family<List<ExpensesRecord>, int>((ref, year) {
  var realmService = ref.watch(realmProvider);

  final stream = realmService!.realm.query<ExpensesRecord>(
    "TRUEPREDICATE SORT(date ASC)",
  );

  List<ExpensesRecord> expenses = [];
  stream.forEach((element) {
    if (element.date!.toLocal().year == year) expenses.add(element);
  });

  return expenses;
});

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
    StateProvider.family<int, ClosingParams>((ref, filter) {
  double totalDonation = 0;
  double totalExpenses = 0;
  double closingBalance = 0;
  log("Year - " + filter.month.toString() + " - " + filter.year.toString());
  var realmService = ref.watch(realmProvider);
  final donars = realmService!.realm
      .query<DonarRecord>(r"date < $0 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year ?? 2022, filter.month!, 1),
  ]);
  log("Total Donation - " + totalDonation.toString());
  donars.forEach((element) {
    totalDonation += element.amount ?? 0;
  });

  final expenses = realmService.realm
      .query<ExpensesRecord>(r"date < $0 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year ?? 2022, filter.month!, 1),
  ]);
   log("Total Expanse - " + totalExpenses.toString());
  expenses.forEach((data) {
    totalExpenses += data.amount ?? 0;
  });

  closingBalance = totalDonation - totalExpenses;

  log("Total Donation - " +
      totalDonation.toString() +
      " - " +
      totalExpenses.toString());

  log("Closing Balance  - " + closingBalance.toString());
  log("-------------------------------------------");

  return closingBalance.truncate();
});

final closingCurrentBalanceDataProvider =
    StateProvider.family<int, ClosingParams>((ref, filter) {
  double totalDonation = 0;
  double totalExpenses = 0;
  double closingBalance = 0;
  log("Closing Year - " +
      filter.month.toString() +
      " - " +
      filter.year.toString());
  var realmService = ref.watch(realmProvider);
  final donars = realmService!.realm
      .query<DonarRecord>(r"date < $0 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year ?? 2022, filter.month!, 1),
  ]);
  log("Total Donation - " + totalDonation.toString());
  donars.forEach((element) {
    totalDonation += element.amount ?? 0;
  });

  final expenses = realmService.realm
      .query<ExpensesRecord>(r"date < $0 AND TRUEPREDICATE SORT(date ASC)", [
    DateTime(filter.year ?? 2022, filter.month!, 1),
  ]);
  log("Total Expense - " + totalExpenses.toString());
  expenses.forEach((data) {
    totalExpenses += data.amount ?? 0;
  });

  closingBalance = totalDonation - totalExpenses;

  log("Total Donation - " +
      totalDonation.toString() +
      " - " +
      totalExpenses.toString());

  log("Closing Balance  - " + closingBalance.toString());
  log("-------------------------------------------");

  return closingBalance.truncate();
});
