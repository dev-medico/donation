// import 'package:donation/realm/realm_services.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:realm/realm.dart';

// final postDataProvider = StreamProvider<RealmResultsChanges<Post>>((ref) {
//   var realmService = ref.watch(realmProvider);
//   final stream =
//       realmService!.realm.query<Post>("TRUEPREDICATE SORT(_id DESC)").changes;

//   return stream;
// });
