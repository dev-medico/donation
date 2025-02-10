// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:donation/realm/schemas.dart';
// import 'package:donation/src/features/donation/controller/donation_provider.dart';

// class DonationListByYearController
//     extends AutoDisposeFamilyStreamNotifier<List<Donation>, int> {
//   @override
//   Stream<List<Donation>> build(int year) async* {
//     final donationData = await ref.watch(donationByYearProvider(arg));
//     yield [
//       for (var donation in donationData) donation,
//     ];
//   }
// }

// final donationListByYearProvider = StreamNotifierProvider.autoDispose
//     .family<DonationListByYearController, List<Donation>, int>(
//         DonationListByYearController.new);
