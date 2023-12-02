import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final membersProvider = StateProvider<RealmResults<Member>>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Member>("TRUEPREDICATE SORT(_id ASC)");
});

final donationsProvider = StateProvider<RealmResults<Donation>>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Donation>("TRUEPREDICATE SORT(_id ASC)");
});

final donationsSortedByDateProvider =
    StateProvider.family<RealmResults<Donation>, String>((ref, memberId) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Donation>(
      r"memberId == $0 AND TRUEPREDICATE SORT(donationDate ASC)", [memberId]);
});

final donationsProviderByGender =
    StateProvider.family<RealmResults<Donation>, String>((ref, gender) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm.query<Donation>(
      r"memberObj.gender == $0 AND TRUEPREDICATE SORT(_id ASC)", [gender]);
});

final totalMembersProvider = StateProvider<int>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm
      .query<Member>("TRUEPREDICATE SORT(_id ASC)")
      .length;
});

final totalPatientProvider = StateProvider<int>((ref) {
  var patients = ref.watch(patientProvider);
  return patients.length;
});

final patientProvider = StateProvider<List<Patient>>((ref) {
  var donations = ref.watch(donationsProvider);
  List<Patient> patients = [];
  donations.forEach((donation) {
    if (patients
        .where((element) => donation.patientName == element.patientName)
        .isEmpty) {
      var patient = Patient(
          patientAddress: donation.patientAddress,
          patientAge: donation.patientAge,
          patientDisease: donation.patientDisease,
          patientName: donation.patientName,
          hospital: donation.hospital,
          donatedCount: 1);
      patients.add(patient);
    } else {
      var patient = patients
          .firstWhere((element) => donation.patientName == element.patientName);
      patient.donatedCount = patient.donatedCount! + 1;
    }
  });
  //sort patients by donated count
  patients.sort((a, b) => b.donatedCount!.compareTo(a.donatedCount!));
  return patients;
});

final totalDonationsProvider = StateProvider<int>((ref) {
  var realmService = ref.watch(realmProvider);
  return realmService!.realm
      .query<Donation>("TRUEPREDICATE SORT(_id ASC)")
      .length;
});

class Patient {
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  String? hospital;
  int? donatedCount;

  Patient(
      {this.patientAddress,
      this.patientAge,
      this.patientDisease,
      this.patientName,
      this.hospital,
      this.donatedCount});
}
