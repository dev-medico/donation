// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:equatable/equatable.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:donation/realm/schemas.dart';
// import 'package:donation/src/features/donation/controller/donation_provider.dart';

// class DonationListController extends AutoDisposeFamilyStreamNotifier<
//     List<Donation>, DonationFilterModel> {
//   @override
//   Stream<List<Donation>> build(DonationFilterModel arg) async* {
//     final donationData =
//         await ref.watch(donationByMonthYearStreamProvider(arg).future);
//     yield [
//       for (var donation in donationData.results) donation,
//     ];
//   }
// }

// final donationListProvider = StreamNotifierProvider.autoDispose
//     .family<DonationListController, List<Donation>, DonationFilterModel>(
//         DonationListController.new);

// class DonationFilterModel extends Equatable {
//   int? year;
//   int? month;

//   DonationFilterModel({
//     this.year,
//     this.month,
//   });

//   @override
//   List<Object> get props => [(year, month)];

//   DonationFilterModel copyWith({
//     int? year,
//     int? month,
//   }) {
//     return DonationFilterModel(
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

//   factory DonationFilterModel.fromMap(Map<String, dynamic> map) {
//     return DonationFilterModel(
//       year: map['year'] != null ? map['year'] as int : null,
//       month: map['month'] != null ? map['month'] as int : null,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory DonationFilterModel.fromJson(String source) =>
//       DonationFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   bool get stringify => true;
// }
