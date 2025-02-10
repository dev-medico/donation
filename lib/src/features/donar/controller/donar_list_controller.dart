// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:donation/src/features/donar/controller/dona_data_provider.dart';
// import 'package:equatable/equatable.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:donation/realm/schemas.dart';
// import 'package:donation/src/features/donation/controller/donation_provider.dart';

// class DonarListController extends AutoDisposeFamilyStreamNotifier<
//     List<DonarRecord>, DonarFilterModel> {
//   @override
//   Stream<List<DonarRecord>> build(DonarFilterModel arg) async* {
//     final donarData =
//         await ref.watch(donarByMonthYearStreamProvider(arg).future);
//     yield [
//       for (var donar in donarData.results) donar,
//     ];
//   }
// }

// final donarListProvider = StreamNotifierProvider.autoDispose
//     .family<DonarListController, List<DonarRecord>, DonarFilterModel>(
//         DonarListController.new);

// class ExpenseListController extends AutoDisposeFamilyStreamNotifier<
//     List<ExpensesRecord>, DonarFilterModel> {
//   @override
//   Stream<List<ExpensesRecord>> build(DonarFilterModel arg) async* {
//     final expenseData =
//         await ref.watch(expenseByMonthYearStreamProvider(arg).future);
//     yield [
//       for (var expense in expenseData.results) expense,
//     ];
//   }
// }

// final expenseListProvider = StreamNotifierProvider.autoDispose
//     .family<ExpenseListController, List<ExpensesRecord>, DonarFilterModel>(
//         ExpenseListController.new);

// class DonarFilterModel extends Equatable {
//   int? year;
//   int? month;

//   DonarFilterModel({
//     this.year,
//     this.month,
//   });

//   @override
//   List<Object> get props => [(year, month)];

//   DonarFilterModel copyWith({
//     int? year,
//     int? month,
//   }) {
//     return DonarFilterModel(
//       year: year ?? this.year,
//       month: month ?? this.month,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'year': year,
//       'month': month,
//     };
//   }

//   factory DonarFilterModel.fromMap(Map<String, dynamic> map) {
//     return DonarFilterModel(
//       year: map['year'] != null ? map['year'] as int : null,
//       month: map['month'] != null ? map['month'] as int : null,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory DonarFilterModel.fromJson(String source) =>
//       DonarFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   bool get stringify => true;
// }
