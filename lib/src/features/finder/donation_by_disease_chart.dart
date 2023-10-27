import 'package:donation/responsive.dart';
import 'package:donation/responsive_two_column_layout.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/finder/most_blood_donation_member.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DonationByDiseaseScreen extends ConsumerStatefulWidget {
  const DonationByDiseaseScreen({super.key});

  @override
  ConsumerState<DonationByDiseaseScreen> createState() =>
      _DonationByDiseaseScreenState();
}

class _DonationByDiseaseScreenState
    extends ConsumerState<DonationByDiseaseScreen> {
  List<DonationModel>? donations;
  @override
  Widget build(BuildContext context) {
    var donationsData = ref.watch(donationsProvider);

    //get top 5 donations by grouping same disease
    donations = donationsData
        .fold<List<DonationModel>>([], (previousValue, element) {
          var index = previousValue.indexWhere(
              (e) => (e.disease == element.patientDisease) && e.disease != "");
          if (index == -1) {
            var product = DonationModel(
              disease: element.patientDisease.toString(),
              quantity: 1,
            );
            previousValue.add(product);
          } else {
            previousValue[index].quantity = previousValue[index].quantity! + 1;
          }
          return previousValue;
        })
        .where((element) => element.quantity != 0)
        .toList();

    // sort donations list by quantity
    donations!.sort((a, b) => b.quantity!.compareTo(a.quantity!));
    //get only top 5 donations
    donations = donations!.length > 8 ? donations!.sublist(0, 8) : donations;

    return ResponsiveTwoColumnLayout(
        spacing: 20,
        startContent: Container(
            margin: EdgeInsets.only(
                left: Responsive.isMobile(context) ? 16 : 20,
                top: Responsive.isMobile(context) ? 16 : 20,
                bottom: Responsive.isMobile(context) ? 32 : 20,
                right: Responsive.isMobile(context) ? 20 : 0),
            child: NeumorphicButton(
                style: NeumorphicStyle(
                  color: Colors.white,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                      Responsive.isMobile(context) ? 12 : 16)),
                  depth: 4,
                  intensity: 0.8,
                  shadowDarkColor: Colors.black,
                  shadowLightColor: Colors.white,
                ),
                onPressed: () async {},
                child: BloodDonationPieChart(donations: donations!))),
        endContent: Container(
          // height: MediaQuery.of(context).size.height * 0.41,
          margin: EdgeInsets.only(
              left: Responsive.isMobile(context) ? 16 : 40,
              top: Responsive.isMobile(context) ? 16 : 20,
              bottom: Responsive.isMobile(context) ? 32 : 20,
              right: Responsive.isMobile(context) ? 20 : 20),
          child: NeumorphicButton(
            style: NeumorphicStyle(
              color: Colors.white,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                  Responsive.isMobile(context) ? 12 : 16)),
              depth: 4,
              intensity: 0.8,
              shadowDarkColor: Colors.black,
              shadowLightColor: Colors.white,
            ),
            onPressed: () async {},
            child: MostBloodDonationMembers(),
          ),
        ));
  }
}
