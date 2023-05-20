import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:donation/data/response/xata_donation_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/donation/donation_chart_by_desease.dart';
import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
import 'package:donation/utils/Colors.dart';

class BloodDonationReportScreen extends StatefulWidget {
  final List<DonationRecord> data;
  final int month;
  final String year;
  const BloodDonationReportScreen(
      {Key? key, required this.data, required this.month, required this.year})
      : super(key: key);

  @override
  State<BloodDonationReportScreen> createState() =>
      _BloodDonationReportScreenState();
}

class _BloodDonationReportScreenState extends State<BloodDonationReportScreen> {
  @override
  void initState() {
    super.initState();
    print(widget.data.length);
  }

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [primaryColor, primaryDark],
          ))),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                "${widget.year} ${months[widget.month]} သွေးလှူဒါန်းမှုမှတ်တမ်း",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: Colors.white)),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: DonationChartByBlood(
                    data: widget.data,
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  flex: 1, child: DonationChartByHospital(data: widget.data)),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  flex: 1, child: DonationChartByDisease(data: widget.data)),
            ],
          ),
        ));
  }
}
