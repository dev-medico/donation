import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/realm/app_services.dart';
import 'package:merchant/realm/realm_services.dart';

final appServiceProvider = ChangeNotifierProvider<AppServices>((ref) {
  String appId = "donation-jurpu";
  Uri baseUrl = Uri.parse("https://realm.mongodb.com");
  return AppServices(appId, baseUrl);
});

final realmServiceProvider = ChangeNotifierProvider<RealmServices?>((ref) {
  final appServices = ref.watch(appServiceProvider);
  return appServices.app.currentUser != null
      ? RealmServices(appServices.app)
      : null;
});
