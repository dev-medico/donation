// /// Package imports
// import 'dart:math';

// import 'package:donation/realm/schemas.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/donar/controller/dona_data_provider.dart';
// import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
// import 'package:donation/src/features/finder/common_chart_data.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class MostBloodDonationMembers extends ConsumerStatefulWidget {
//   MostBloodDonationMembers({
//     super.key,
//   });

//   @override
//   ConsumerState<MostBloodDonationMembers> createState() =>
//       _MostBloodDonationMembersState();
// }

// class _MostBloodDonationMembersState
//     extends ConsumerState<MostBloodDonationMembers> {
//   _MostBloodDonationMembersState();

//   @override
//   Widget build(BuildContext context) {
//     var mostBloodDonationMembers = ref.watch(membersDataProvider);
//     //sort mostBloodDonationMembers by total count
//     List<Member> members = [];
//     mostBloodDonationMembers.forEach((value) {
//       members.add(value);
//     });
//     members.sort((a, b) => int.parse(b.totalCount == "" || b.totalCount == null
//             ? "0"
//             : b.totalCount.toString())
//         .compareTo(int.parse(a.totalCount == "" || a.totalCount == null
//             ? "0"
//             : a.totalCount.toString())));
//     return Container(
//       height: Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.height * 0.65
//           : MediaQuery.of(context).size.height * 0.5,
//       width: Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.width * 0.9
//           : MediaQuery.of(context).size.width * 0.43,
//       child: ListView(
//         shrinkWrap: true,
//         physics: Responsive.isMobile(context)
//             ? NeverScrollableScrollPhysics()
//             : BouncingScrollPhysics(),
//         children: [
//           SizedBox(
//             height: 8,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Text(
//               "လှူဒါန်းမှု အများဆုံး အဖွဲ့ဝင်များ",
//               style: TextStyle(
//                   fontSize: Responsive.isMobile(context) ? 16.5 : 17.5,
//                   color: primaryColor,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(
//             height: Responsive.isMobile(context) ? 10 : 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: Text(
//                   "အမည်",
//                   style: TextStyle(
//                       fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Text(
//                 "အရေအတွက်",
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: Responsive.isMobile(context)
//                 ? const NeverScrollableScrollPhysics()
//                 : const BouncingScrollPhysics(),
//             padding: const EdgeInsets.only(right: 12, left: 16, top: 8),
//             itemCount: 11,
//             itemBuilder: (BuildContext context, int index) {
//               return Padding(
//                 padding: const EdgeInsets.all(0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           Utils.strToMM((index + 1).toString()) + "။ ",
//                           style: TextStyle(
//                             fontSize: Responsive.isMobile(context) ? 15 : 16,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Text(
//                           members[index].name.toString(),
//                           style: TextStyle(
//                             fontSize: Responsive.isMobile(context) ? 15 : 16,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Text(
//                           "  ( " + members[index].memberId.toString() + " )",
//                           style: TextStyle(
//                             fontSize: Responsive.isMobile(context) ? 15 : 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       members[index].totalCount.toString(),
//                       style: TextStyle(
//                         fontSize: Responsive.isMobile(context) ? 15 : 16,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
