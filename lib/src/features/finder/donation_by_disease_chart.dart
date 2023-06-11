import 'package:donation/responsive.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
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

    return Container(
      margin: EdgeInsets.only(
          left: 20, top: 20, right: MediaQuery.of(context).size.width * 0.34),
      child: NeumorphicButton(
        style: NeumorphicStyle(
          color: Colors.white,
          boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16)),
          depth: 4,
          intensity: 0.8,
          shadowDarkColor: Colors.black,
          shadowLightColor: Colors.white,
        ),
        onPressed: () async {},
        child: Row(
          children: [
            Expanded(child: BloodDonationPieChart(donations: donations!)),
            Container(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
