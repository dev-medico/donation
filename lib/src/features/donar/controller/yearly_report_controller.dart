import 'dart:developer';

import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donar/controller/dona_data_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class YearlyReportController
    extends FamilyStreamNotifier<List<YearReportData>, int> {
  @override
  Stream<List<YearReportData>> build(int year) async* {
    log(year.toString() + " Y");
    final donars = ref.watch(donarByYearProvider(year));
    final expenses = ref.watch(expenseByYearProvider(year));

    Map<String, DonarRecord> listMapDonors = {};
    Map<String, ExpensesRecord> listMapExpense = {};

    log('${donars.length}         year');
    for (var i in donars) {
      listMapDonors.update(
          DateFormat.LLLL().format(i.date!),
          (value) => DonarRecord(
                i.id,
                amount: ((i.amount ?? 0) + (value.amount ?? 0)),
                date: i.date,
                name: i.name,
              ),
          ifAbsent: () => DonarRecord(
                i.id,
                amount: i.amount ?? 0,
                name: i.name!,
                date: i.date,
              ));
    }

    for (var i in expenses) {
      listMapExpense.update(
          DateFormat.LLLL().format(i.date!),
          (value) => ExpensesRecord(
                i.id,
                amount: ((i.amount ?? 0) + (value.amount ?? 0)),
                date: i.date,
                name: i.name,
              ),
          ifAbsent: () => ExpensesRecord(
                i.id,
                amount: i.amount!,
                name: i.name!,
                date: i.date,
              ));
    }

    yield [
      for (int i = 0; i < listMapDonors.entries.length; i++)
        YearReportData(
            month: DateFormat.LLLL()
                .format(listMapDonors.entries.elementAt(i).value.date!),
            totalDonation: listMapDonors.entries.elementAt(i).value.amount,
            totalExpenses: listMapExpense.entries
                    .where((element) =>
                        DateFormat.LLLL().format(element.value.date!) ==
                        DateFormat.LLLL().format(
                            listMapDonors.entries.elementAt(i).value.date!))
                    .firstOrNull
                    ?.value
                    .amount ??
                0)
    ];
  }
}

final yearlyReportControllerProvider = StreamNotifierProviderFamily<
    YearlyReportController,
    List<YearReportData>,
    int>(YearlyReportController.new);

class YearReportData {
  String? month;
  int? totalDonation;
  int? totalExpenses;

  YearReportData({this.month, this.totalDonation, this.totalExpenses});
}
